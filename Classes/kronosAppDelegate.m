//
//  kronos1AppDelegate.m
//  kronos1
//
//  Created by Ljuba Miljkovic on 3/14/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

//CUSTOM NAVIGATION BAR

@interface UINavigationBar (MyCustomNavBar)
@end
@implementation UINavigationBar (MyCustomNavBar)
- (void) drawRect:(CGRect)rect {
    UIImage *barImage = [UIImage imageNamed:@"seg-topbar.png"];
    [barImage drawInRect:rect];
}
@end

#import "kronosAppDelegate.h"
#import "DataImporter.h"
#import "Stop.h"
#import "DataHelper.h"
#import "BartStopDetails.h"
#import "NextBusStopDetails.h"
#import "FavoritesVC.h"
#import "NearMeVC.h"
#import "DirectionsVC.h"
#import "StopsTVC.h"
#import "LinesVC.h"
#import "LiveRouteTVC.h"
#import "FlurryAnalytics.h"
#import "TouchXML.h"
#import "FlurryAnalytics.h"
#import "Appirater.h"

@implementation kronosAppDelegate


@synthesize window, tabBarController, predictionsManager, importing, updateManager;


#pragma mark -
#pragma mark Application lifecycle

- (void) applicationDidFinishLaunching:(UIApplication *)application {
	
    //[DataImporter importTransitData]; return;
	
	//PUBLIC
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"config.plist"];
    NSDictionary *configData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
	NSString *flurryKey = [configData valueForKey:@"flurryKey"];

    [FlurryAnalytics startSession:flurryKey];
	
    [FlurryAnalytics setSessionReportsOnCloseEnabled:NO];
    [FlurryAnalytics setSessionReportsOnPauseEnabled:NO];

	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque]; 
	
	self.predictionsManager = [[PredictionsManager alloc] init];
	
	self.updateManager = [[UpdateManager alloc] init];
	
	[self.updateManager checkForLocalUpdate];
	
	//[updateManager performSelectorInBackground:@selector(checkForRemoteUpdate) withObject:nil];
	
    //only restore if there hasn't been a data change
	if ([self secondsSinceLastLaunch] > 20*60 || self.updateManager.dataUpdated) {
		
		//load last root view controller if any
        
		[self restoreToSavedRootViewController];
		
	}
	else {
		//restore saved view controller stack, if any
        [self restoreFromDefaults];
		
	}
	
	[self.window addSubview:self.tabBarController.view];
	[self.window makeKeyAndVisible];
	
	[Appirater appLaunched:YES];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"restoring in foreground");
	
	if ([self secondsSinceLastLaunch] > 20*60) {
		
		//pop to root view controller
		UINavigationController *currController = (UINavigationController *)[self.tabBarController selectedViewController];
		[currController popToRootViewControllerAnimated:NO];
		
	}
	else {
		//do nothing. everything should be fine
		
	}
	
	[self.updateManager performSelectorInBackground:@selector(checkForRemoteUpdate) withObject:nil];
	
	[Appirater appEnteredForeground:YES];
	
}

- (NSTimeInterval)secondsSinceLastLaunch {
	
	NSDate *activeAt = [NSDate dateWithTimeIntervalSinceNow:0];
	NSDate *inactiveAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"dateOfLastQuit"];
	
	return [activeAt timeIntervalSinceDate:inactiveAt];
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"applicationDidEnterBackground, saving state");
	[self saveState];
}


- (void)tabBarController:(UITabBarController *)_tabBarController didSelectViewController:(UIViewController *)viewController {
	
	int tabIndex = [_tabBarController selectedIndex];
	
	//always show the root view controller in the favorites, near me, and lines sections
	if (tabIndex == 0 || tabIndex == 1 || tabIndex == 2) {
		[(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
	}
	
}


#pragma mark -
#pragma mark Saving and Restoring State	

- (void)saveState {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:self.tabBarController.selectedIndex+1 forKey:@"tabBarControllerSelectedIndexPlusOne"];
	[userDefaults setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"dateOfLastQuit"];
	
	//if the currently visible view controller is the StopDetails/LiveRoute View Controller, save that stop
	if ([self.tabBarController.selectedViewController isMemberOfClass:[UINavigationController class]]) {
		
		UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
		if ([navController.topViewController isKindOfClass:[StopDetails class]]) {
			NSLog(@"StopDetails Saved"); /* DEBUG LOG */
			
			Stop *stop = [(StopDetails *)(navController.topViewController) stop];
			
			[DataHelper saveStopObjectIDInUserDefaults:stop];
			[userDefaults setObject:@"StopDetails" forKey:@"savedViewController"];
		}
		else if ([navController.topViewController isMemberOfClass:[LiveRouteTVC class]]) {
			NSLog(@"LiveRoute Saved"); /* DEBUG LOG */
			
			LiveRouteTVC *liveRouteTVC = (LiveRouteTVC *)navController.topViewController;
			
			Stop *stop = [liveRouteTVC startingStop];
			Direction *direction = [liveRouteTVC direction];
			
			[DataHelper saveStopObjectIDInUserDefaults:stop];
			[DataHelper saveDirectionIDInUserDefaults:direction forKey:@"liveRouteDirectionURIData"];
			
			[userDefaults setObject:@"LiveRoute" forKey:@"savedViewController"];
		}
		else {
			//if the current view controller isn't a stopDetailsVC or LiveRoute , erase the currently saved stop
			[userDefaults removeObjectForKey:@"stopURIData"];
			[userDefaults removeObjectForKey:@"mainDirectionURIData"];
			[userDefaults removeObjectForKey:@"savedViewController"];
			[userDefaults removeObjectForKey:@"liveRouteDirectionURIData"];
		}
	}
	
	[userDefaults synchronize];
		
}

		 
- (void)restoreToSavedRootViewController {		 
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	int tabIndexPlusOne = [userDefaults integerForKey:@"tabBarControllerSelectedIndexPlusOne"];	
	
	//if there is a saved tab index, restore to it
	if (tabIndexPlusOne != 0) {
		
		int tabIndex = tabIndexPlusOne - 1;
		[self.tabBarController setSelectedIndex:tabIndex];
		
	}
	else {
		//otherwise, just go to nearme
		[self.tabBarController setSelectedIndex:1];
	}

}
		 
		 
- (void)restoreFromDefaults {
	
	Stop *savedStop = [self savedStopFromUserDefaults];
	
	[self restoreToSavedRootViewController];
	
	//load the stopDetailsVC if there is a saved stop in the user defaults		
	
	if (savedStop != nil) {
		[self restoreDetailsWithStop:savedStop];
	}

}


- (void)restoreDetailsWithStop:(Stop *)savedStop {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	NSLog(@"  -restore savedViewController: %@",[userDefaults objectForKey:@"savedViewController"]);

	
	int tabIndex = [self.tabBarController selectedIndex];
	
	//favorites tab
	if (tabIndex == 0) {
		
		NSLog(@"App Delegate: Reload StopDetailsVC in Favorites"); /* DEBUG LOG */
		
		UINavigationController *favoritesNavController = [self.tabBarController.viewControllers objectAtIndex:tabIndex];	
		
		//favorites VC is already loaded from nib
		FavoritesVC *favoritesVC = (FavoritesVC *)[favoritesNavController topViewController];
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Favorites" style:UIBarButtonItemStylePlain target:nil action:nil];
		favoritesVC.navigationItem.backBarButtonItem = backButton;		
		
		[self restoreStopDetailsWithStop:savedStop mainDirection:nil toNavController:favoritesNavController];
		
		//load liveRoute if that was the last view controller on shut down
		if ([[userDefaults objectForKey:@"savedViewController"] isEqual:@"LiveRoute"]) {
			
			[self restoreLiveRouteWithStartingStop:savedStop toNavController:favoritesNavController];
			
		}
	}
	//near me tab
	else if (tabIndex == 1) {
		
		NSLog(@"App Delegate: Reload StopDetailsVC in Near Me"); /* DEBUG LOG */
		
		UINavigationController *nearMeNavController = [self.tabBarController.viewControllers objectAtIndex:tabIndex];	

		//near me vc is already loaded from the nib in this case. we just need to set the backButton title
		NearMeVC *nearMeVC = (NearMeVC *)[nearMeNavController topViewController];

		NSString *backTitle = [NSString stringWithString:@"Map"];
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
		nearMeVC.navigationItem.backBarButtonItem = backButton;

		[self restoreStopDetailsWithStop:savedStop mainDirection:nil toNavController:nearMeNavController];

		//load liveRoute if that was the last view controller on shut down
		if ([[userDefaults objectForKey:@"savedViewController"] isEqual:@"LiveRoute"]) {
	
			[self restoreLiveRouteWithStartingStop:savedStop toNavController:nearMeNavController];
			
		}
		
	}
	else if (tabIndex == 2) {
		
		NSLog(@"App Delegate: Reload StopDetailsVC in Lines"); /* DEBUG LOG */
		
		UINavigationController *linesNavController = [self.tabBarController.viewControllers objectAtIndex:tabIndex];	
		
		//restore the saved main Direction from 
		Direction *mainDirection = [self savedDirectionFromUserDefaultsForKey:@"mainDirectionURIData"];
		
		//near me vc is already loaded from the nib in this case. we just need to set the backButton title
		LinesVC *linesVC = (LinesVC *)[linesNavController topViewController];
		
		NSString *backTitle = [NSString stringWithString:@"Lines"];
		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
		linesVC.navigationItem.backBarButtonItem = backButton;
		
		if ([[[DataHelper agencyFromStop:savedStop] shortTitle] isEqual:@"bart"]) {
			
			[self restoreStopDetailsWithStop:savedStop mainDirection:nil toNavController:linesNavController];
			
			//load liveRoute if that was the last view controller on shut down
			if ([[userDefaults objectForKey:@"savedViewController"] isEqual:@"LiveRoute"]) {
				
				[self restoreLiveRouteWithStartingStop:savedStop toNavController:linesNavController];
				
			}
			
		}
		else {
			
			//load directions VC and set it's route
			DirectionsVC *directionsVC = [[DirectionsVC alloc] init];
			directionsVC.route = mainDirection.route;
			
			NSString *directionsBackTitle = [NSString stringWithString:@"Directions"];
			UIBarButtonItem *directionsBackButton = [[UIBarButtonItem alloc] initWithTitle:directionsBackTitle style:UIBarButtonItemStylePlain target:nil action:nil];
			directionsVC.navigationItem.backBarButtonItem = directionsBackButton;					
			
			[linesNavController pushViewController:directionsVC animated:NO];
			
			//load stops screen
			StopsTVC *stopsTVC = [[StopsTVC alloc] init];
			stopsTVC.direction = mainDirection;
			
			NSString *stopsBackTitle = [NSString stringWithFormat:@"%@ Stops", mainDirection.route.tag];
			UIBarButtonItem *stopBackButton = [[UIBarButtonItem alloc] initWithTitle:stopsBackTitle style:UIBarButtonItemStylePlain target:nil action:nil];
			stopsTVC.navigationItem.backBarButtonItem = stopBackButton;
			
			[linesNavController pushViewController:stopsTVC animated:NO];
			
			[self restoreStopDetailsWithStop:savedStop mainDirection:mainDirection toNavController:linesNavController];
						
			//load liveRoute if that was the last view controller on shut down
			if ([[userDefaults objectForKey:@"savedViewController"] isEqual:@"LiveRoute"]) {
				
				[self restoreLiveRouteWithStartingStop:savedStop toNavController:linesNavController];
				
			}
			
		}
		
	}
	
}

- (void)restoreLiveRouteWithStartingStop:(Stop *)stop toNavController:(UINavigationController *)navController {
	
	LiveRouteTVC *liveRouteTVC = [[LiveRouteTVC alloc] init];
	liveRouteTVC.startingStop = stop;
	liveRouteTVC.direction = [self savedDirectionFromUserDefaultsForKey:@"liveRouteDirectionURIData"];
	[navController pushViewController:liveRouteTVC animated:NO];
	
}

- (void)restoreStopDetailsWithStop:(Stop *)stop mainDirection:(Direction *)mainDirection toNavController:(UINavigationController *)navController {

	NSLog(@"restoring stop details");
	
	NSString *backTitle = [NSString stringWithString:@"Stop"];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
	
	
	
	NextBusStopDetails *nextBusStopDetails;
	BartStopDetails *bartStopDetails;
	
	NSString *agencyShortTitle = [[DataHelper agencyFromStop:stop] shortTitle];
	
	if ([agencyShortTitle isEqualToString:@"bart"]){
	
		bartStopDetails = [[BartStopDetails alloc] initWithStop:stop];
		bartStopDetails.navigationItem.backBarButtonItem = backButton;
		[navController pushViewController:bartStopDetails animated:NO];
		
		
	}
	else {
		
		nextBusStopDetails = [[NextBusStopDetails alloc] initWithStop:stop];
		
		if (mainDirection != nil) {
			nextBusStopDetails.mainDirection = mainDirection;
		}
		
		nextBusStopDetails.navigationItem.backBarButtonItem = backButton;
		[navController pushViewController:nextBusStopDetails animated:NO];
	}
}

- (Stop *)savedStopFromUserDefaults {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSData *data = [userDefaults dataForKey:@"stopURIData"];
		
	if (data == nil) {
		return nil;
	}
	
	NSURL *url = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
	NSManagedObjectID *stopID = [storeCoordinator managedObjectIDForURIRepresentation:url];
		
	NSManagedObjectContext *objectContext = [self managedObjectContext];
	return (Stop *)[objectContext objectWithID:stopID];

}

- (Direction *)savedDirectionFromUserDefaultsForKey:(NSString *)key {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSData *data = [userDefaults dataForKey:key];
	
	if (data == nil) {
		return nil;
	}
	
	NSURL *url = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	NSPersistentStoreCoordinator *storeCoordinator = [self persistentStoreCoordinator];
	NSManagedObjectID *directionID = [storeCoordinator managedObjectIDForURIRepresentation:url];

	NSManagedObjectContext *objectContext = [self managedObjectContext];
	return (Direction *)[objectContext objectWithID:directionID];
	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"applicationWillTerminate");
	[self saveState];
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil && !importing) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil && !importing) {
        return persistentStoreCoordinator;
    }
	
	NSURL *storeUrl;
	
	if (importing) {

        storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"kronos.sqlite"];        
        
	}
	else {
		storeUrl = [NSURL fileURLWithPath: [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent: @"kronos.sqlite"]];
        
	}

    

	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:1]
                                                                                                                                                     forKey:NSReadOnlyPersistentStoreOption] error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    

	
    return persistentStoreCoordinator;
}



#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end

