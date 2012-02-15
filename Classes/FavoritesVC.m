//
//  FavoritesVC.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FavoritesVC.h"
#import "PredictionsManager.h"
#import "PredictionRequest.h"
#import "kronosAppDelegate.h"
#import "NextBusStopDetails.h"
#import "BartStopDetails.h"
#import "ParticipateVC.h"

@implementation FavoritesVC

@synthesize segmentedControl, tableView, reloadPredictionsButton, timer, stopsDelegate, editButton, noFavoritesMessageView, participateButton;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	//general settings
	self.navigationItem.title = @"Favorite Stops";
	
	//SETUP NO-FAVORITES MESSAGE VIEW
	noFavoritesMessageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-favorites-message.png"]];
	noFavoritesMessageView.center = CGPointMake(160, 170);
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Favorites" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];		
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Stops", @"Trips", nil]];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl addTarget:self action:@selector(tapSegmentedControl) forControlEvents:UIControlEventValueChanged];
	segmentedControl.selectedSegmentIndex = 0;
	[segmentedControl setWidth:95.0 forSegmentAtIndex:0];
	[segmentedControl setWidth:95.0 forSegmentAtIndex:1];
	segmentedControl.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
	
	//VERSION 1: Remove this to support trip planning
	//self.navigationItem.titleView = segmentedControl;
	
	//setup the favorites delegates
	stopsDelegate = [[FavoriteStopsDelegate alloc] init];
    

//    participateButton = [[UIButton alloc] init];
//    participateButton.frame = CGRectMake(0, 0, 320, 60);
//    [participateButton setImage:[UIImage imageNamed:@"participate-button.png"] forState:UIControlStateNormal];
//    [participateButton setTitle:@"Participate" forState:UIControlStateNormal];
//    [participateButton addTarget:self action:@selector(showParticipateView) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:participateButton];
    
	
}

- (void)showParticipateView {
    
    [FlurryAnalytics logEvent:@"Show Participation Message"];
    
    UIViewController *participateVC = [[ParticipateVC alloc] init];
    [self.navigationController pushViewController:participateVC animated:YES];
    
    [participateVC release];
    
    
}


//turns off the timer that fetches predictions when the app is locked, and turns it back on again when it unlocks
- (void)toggleRequestPredictionsTimer:(NSNotification *)note {
		
	if ([note.name isEqual:UIApplicationWillResignActiveNotification]) {
		
		NSLog(@"FAVORITESVC: Prediction Requests OFF"); /* DEBUG LOG */

		[timer invalidate];
	}
	else if ([note.name isEqual:UIApplicationDidBecomeActiveNotification]) {
		
		NSLog(@"FAVORITESVC: Prediction Requests ON"); /* DEBUG LOG */
		[tableView reloadData];
		[stopsDelegate.predictions removeAllObjects];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestPredictions) userInfo:nil repeats:YES];
		[timer fire];
	}
	
}


//load the favorites file everytime the view appears, not just when it loads
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    //check the segmented control selection and load the appropriate favorites
	//request predictions if you're looking at stops
	[self tapSegmentedControl];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL declinedToParticipate = [userDefaults boolForKey:@"declinedToParticipate"];
    
    //don't show the participate banner. force this choice.
    if ((declinedToParticipate=YES)) {
        
        tableView.frame = CGRectMake(0, 0, 320, 367);
        participateButton.hidden = YES;
        
    }
    //show the participate banner
    else {
        
        participateButton.hidden = NO;
        tableView.frame = CGRectMake(0, 60, 320, 307);
        
        
    }
    
    [self.view setNeedsLayout];
    
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	//set time to fetch predictions every 20 seconds
	self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestPredictions) userInfo:nil repeats:YES];
	//predictions are requested in tapsegmentedcontrol
	
	//setup notification observing for when a user taps on a favorite stop
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(loadNextViewController:) name:@"favoriteStopSelected" object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationDidBecomeActiveNotification object:nil];
	//[notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationDidEnterBackgroundNotification object:nil];

	
}

//stop the automatic fetching of predictions once the view is gone
- (void)viewWillDisappear:(BOOL)animated {
	
	NSLog(@"FAVORITES: VIEW WILL DISAPPEAR"); /* DEBUG LOG */
	
	[super viewWillDisappear:animated];
	
	[timer invalidate];
	
	//unregister the notification from the favorites delegates
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];	
	
}

- (IBAction)toggleEditingMode {
	
	//if in editing mode, turn in off
	if (tableView.editing) {
		
		[tableView setEditing:NO animated:YES];
		
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditingMode)];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];	
		
		//save contents to favorites to capture and changes to the order
		[stopsDelegate saveContentsToFavoritesFile];
		
		
		
	}
	else {
		[tableView setEditing:YES animated:YES];
		
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditingMode)];
		self.navigationItem.rightBarButtonItem = rightButton;
		[rightButton release];	
		

		
	}
}


//submits a request to the PredictionsManager for predictions of the displayed stops/routes. the results will come to the FavoriteStops Delegate
- (void)requestPredictions {
	
	//only load predictions for the stops screen. trips don't need predictions
	if (segmentedControl.selectedSegmentIndex == 0) {
				
		kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
		PredictionsManager *predictionsManager = appDelegate.predictionsManager;
				
		//NSLog(@"%@", self.favoritesDelegate.contents); /* DEBUG LOG */
		
		//only request predictions of there are favorited stops
		if ([stopsDelegate.contents count] > 0) {
						
			NSMutableArray *requests = [NSMutableArray array];
			
			//iterate through the stops on screen and create prediction requests from them
			for (NSDictionary *stopItem in stopsDelegate.contents) {
				
				NSString *agencyShortTitle = [stopItem valueForKey:@"agencyShortTitle"];
				NSString *stopTag = [stopItem valueForKey:@"tag"];
				
				if ([agencyShortTitle isEqual:@"bart"]) {
					
					PredictionRequest *request = [[PredictionRequest alloc] init];
					request.isMainRoute = NO;
					request.agencyShortTitle = agencyShortTitle;
					request.stopTag = stopTag;
					
					[requests addObject:request];
					[request release];
					
	
				}
				else {
					
					//iterate through the directions for all the stops to create prediction requests from them
					for (NSDictionary *directionItem in [stopItem objectForKey:@"lines"]) {
						
						PredictionRequest *request = [[PredictionRequest alloc] init];
						request.stopTag = stopTag;
						request.route = [DataHelper routeWithTag:[directionItem valueForKey:@"routeTag"] inAgencyWithShortTitle:agencyShortTitle];
						request.agencyShortTitle = agencyShortTitle;
						request.isMainRoute = NO;
						
						[requests addObject:request];
						[request release];
					}

				}

			}
						
			//request predictions for the stops in the favorites screen
			[NSThread detachNewThreadSelector:@selector(requestPredictionsForRequests:) toTarget:predictionsManager withObject:requests];
			NSLog(@"FavoritesVC: predictions requested"); /* DEBUG LOG */
		}
			
	}

}

//method called when PredictionsManager returns predictions. set the predictions variable in the favoritestops delegate and reload the tableview
- (void)didReceivePredictions:(NSDictionary *)predictions {
	
	//only load predictions for the stops screen. trips don't need predictions
	//NSLog(@"FavoritesVC: didReceivePredictions: %d", [predictions count]); /* DEBUG LOG */
	
	//only return predicitons if they're not an error
	//or if if the table is not editing
	if ([predictions objectForKey:@"error"] != nil || [tableView isEditing]) {
		return;
	}
	
	//find the index paths of the rows these predictions are for
	NSMutableArray *indexPaths = [NSMutableArray array];
	for (NSString *predictionKey in [predictions allKeys]) {
		
		Prediction *prediction = [predictions objectForKey:predictionKey];
		
		NSPredicate *stopFilter = [NSPredicate predicateWithFormat:@"tag == %@",prediction.stopTag];
		NSPredicate *agencyFilter = [NSPredicate predicateWithFormat:@"agencyShortTitle == %@",prediction.agencyShortTitle];
		
		NSMutableArray *matchingStops = [NSMutableArray arrayWithArray:[stopsDelegate.contents filteredArrayUsingPredicate:stopFilter]];
		[matchingStops filterUsingPredicate:agencyFilter];
		
		for (NSDictionary *stopItem in matchingStops) {
			
			//NSLog(@"MATCHING STOP ITEM: %@", stopItem); /* DEBUG LOG */
			
			int rowIndex = [stopsDelegate.contents indexOfObject:stopItem];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
			
			//since favorite stops with multiple lines have multiple predictions, 
			//only add the index path to the array of index paths to update once
			if (![indexPaths containsObject:indexPath]) {
				[indexPaths addObject:indexPath];
			}
		}
		
	}
	
	[stopsDelegate.predictions addEntriesFromDictionary:predictions];

	//NSLog(@"FavoritesVC: cells reloaded: %d", [indexPaths count]); /* DEBUG LOG */
	
	//reload the cells for these predictions
	[tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];

}


//responds to the tap of the favorites segmented control and loads the appropriate favorites (stops or trips)
- (void)tapSegmentedControl {
	
	//stops
	if (segmentedControl.selectedSegmentIndex == 0) {
		reloadPredictionsButton.enabled = YES;
		
		//reload table contents from the favorites.plist file
		[stopsDelegate loadFavoritesFile];		
		
		self.tableView.dataSource = stopsDelegate;
		self.tableView.delegate = stopsDelegate;
		
		//SETTINGS FOR WHEN THERE ARE NO FAVORITE STOPS
		int numberOfFavorites = [stopsDelegate.contents count];
		
		[FlurryAnalytics logEvent:@"Favorites - viewDidLoad" withParameters:
		 [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"d",numberOfFavorites] forKey:@"number of favorites"]];

		if (numberOfFavorites == 0) {
			[self.view addSubview:noFavoritesMessageView];
			self.navigationItem.rightBarButtonItem.enabled = NO;
		}
		else if (numberOfFavorites == 1) {
			self.navigationItem.rightBarButtonItem.enabled = NO;
			[noFavoritesMessageView removeFromSuperview];
		}
		else {
			self.navigationItem.rightBarButtonItem.enabled = YES;		
			[noFavoritesMessageView removeFromSuperview];
			
		}
		
		[self requestPredictions];
		
	}
	//trips
	else if (segmentedControl.selectedSegmentIndex == 1){
		reloadPredictionsButton.enabled = NO;
		self.tableView.dataSource = nil;
		self.tableView.delegate = nil;
		
		[noFavoritesMessageView removeFromSuperview];
	}

	[tableView reloadData];
	
	//NSIndexPath *topPath = [NSIndexPath indexPathForRow:0 inSection:0];
	//[tableView scrollToRowAtIndexPath:topPath atScrollPosition: UITableViewScrollPositionNone animated:NO];

	
}

//loads the stop screen if a favorite stop is selected or a trip screen is a favorite trip is selected
- (void)loadNextViewController:(NSNotification *)note {


	//if a favorite stop was selected
	if (note.name == @"favoriteStopSelected") {

		Stop *stop = (Stop *)note.object;
		NSString *agencyShortTitle = [[DataHelper agencyFromStop:stop] shortTitle];
		
		//SEND FLURRY DATA
		[FlurryAnalytics logEvent:@"Favorites - Stop Selected" withParameters:[DataHelper dictionaryFromStop:stop]];
		
		if ([agencyShortTitle isEqualToString:@"bart"]) {
			BartStopDetails *bartStopDetails = [[BartStopDetails alloc] init];
			bartStopDetails.stop = (Stop *)note.object;
			
			[self.navigationController pushViewController:bartStopDetails animated:YES];
			[bartStopDetails release];
		}
		else {
			NextBusStopDetails *stopDetails = [[NextBusStopDetails alloc] init];
			stopDetails.stop = (Stop *)note.object;
			
			[self.navigationController pushViewController:stopDetails animated:YES];
			[stopDetails release];
		}
	}

}

#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.

	self.tableView = nil;
	self.reloadPredictionsButton = nil;
	self.editButton = nil;
}


- (void)dealloc {

	[timer release];
	[noFavoritesMessageView release];
	[segmentedControl release];
	[stopsDelegate release];
    [participateButton release];
	
    [super dealloc];
}


@end
