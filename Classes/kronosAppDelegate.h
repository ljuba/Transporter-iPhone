//
// kronos1AppDelegate.h
// kronos1
//
// Created by Ljuba Miljkovic on 3/14/10.
// Copyright __MyCompanyName__ 2010. All rights reserved.
//
#import "PredictionsManager.h"
#import "Stop.h"

@interface kronosAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

	NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;

	PredictionsManager *predictionsManager;

	UIWindow *window;
	UITabBarController *tabBarController;

	BOOL importing;

}

@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) PredictionsManager *predictionsManager;

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet UITabBarController *tabBarController;
@property BOOL importing;

- (NSTimeInterval) secondsSinceLastLaunch;
- (void) restoreToSavedRootViewController;

- (Stop *) savedStopFromUserDefaults;
- (Direction *) savedDirectionFromUserDefaultsForKey:(NSString *)key;
- (void) saveState;
- (void) restoreFromDefaults;
- (void) restoreDetailsWithStop:(Stop *)savedStop;
- (void) restoreLiveRouteWithStartingStop:(Stop *)stop toNavController:(UINavigationController *)navController;
- (void) restoreStopDetailsWithStop:(Stop *)stop mainDirection:(Direction *)mainDirection toNavController:(UINavigationController *)navController;
- (NSURL *) applicationDocumentsDirectory;

@end
