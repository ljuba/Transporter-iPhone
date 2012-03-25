//
// FavoritesVC.m
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BartStopDetails.h"
#import "FavoritesVC.h"
#import "NextBusStopDetails.h"
#import "PredictionRequest.h"
#import "PredictionsManager.h"
#import "kronosAppDelegate.h"

@implementation FavoritesVC

@synthesize segmentedControl, tableView, reloadPredictionsButton, timer, stopsDelegate, editButton, noFavoritesMessageView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[super viewDidLoad];

	// general settings
	self.navigationItem.title = @"Favorite Stops";

	// SETUP NO-FAVORITES MESSAGE VIEW
	self.noFavoritesMessageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-favorites-message.png"]];
	self.noFavoritesMessageView.center = CGPointMake(160, 170);

	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Favorites" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;

	self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Stops", @"Trips", nil]];
	self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[self.segmentedControl addTarget:self action:@selector(tapSegmentedControl) forControlEvents:UIControlEventValueChanged];
	self.segmentedControl.selectedSegmentIndex = 0;
	[self.segmentedControl setWidth:95.0 forSegmentAtIndex:0];
	[self.segmentedControl setWidth:95.0 forSegmentAtIndex:1];
	self.segmentedControl.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];

	// VERSION 1: Remove this to support trip planning
	// self.navigationItem.titleView = segmentedControl;

	// setup the favorites delegates
	self.stopsDelegate = [[FavoriteStopsDelegate alloc] init];

}

// turns off the timer that fetches predictions when the app is locked, and turns it back on again when it unlocks
- (void) toggleRequestPredictionsTimer:(NSNotification *)note {

	if ([note.name isEqual:UIApplicationWillResignActiveNotification]) {

		NSLog(@"FAVORITESVC: Prediction Requests OFF"); /* DEBUG LOG */

		[self.timer invalidate];
	} else if ([note.name isEqual:UIApplicationDidBecomeActiveNotification]) {

		NSLog(@"FAVORITESVC: Prediction Requests ON"); /* DEBUG LOG */
		[self.tableView reloadData];
		[self.stopsDelegate.predictions removeAllObjects];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestPredictions) userInfo:nil repeats:YES];
		[self.timer fire];
	}
}

// load the favorites file everytime the view appears, not just when it loads
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// check the segmented control selection and load the appropriate favorites
	// request predictions if you're looking at stops
	[self tapSegmentedControl];

}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// set time to fetch predictions every 20 seconds
	self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestPredictions) userInfo:nil repeats:YES];
	// predictions are requested in tapsegmentedcontrol

	// setup notification observing for when a user taps on a favorite stop
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(loadNextViewController:) name:@"favoriteStopSelected" object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationDidBecomeActiveNotification object:nil];
	// [notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

// stop the automatic fetching of predictions once the view is gone
- (void) viewWillDisappear:(BOOL)animated {

	NSLog(@"FAVORITES: VIEW WILL DISAPPEAR"); /* DEBUG LOG */

	[super viewWillDisappear:animated];

	[self.timer invalidate];

	// unregister the notification from the favorites delegates
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];

}

- (IBAction) toggleEditingMode {

	// if in editing mode, turn in off
	if (self.tableView.editing) {

		[self.tableView setEditing:NO animated:YES];

		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditingMode)];
		self.navigationItem.rightBarButtonItem = rightButton;

		// save contents to favorites to capture and changes to the order
		[self.stopsDelegate saveContentsToFavoritesFile];

	} else {
		[self.tableView setEditing:YES animated:YES];

		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditingMode)];
		self.navigationItem.rightBarButtonItem = rightButton;

	}
}

// submits a request to the PredictionsManager for predictions of the displayed stops/routes. the results will come to the FavoriteStops Delegate
- (void) requestPredictions {

	// only load predictions for the stops screen. trips don't need predictions
	if (self.segmentedControl.selectedSegmentIndex == 0) {

		kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
		PredictionsManager *predictionsManager = appDelegate.predictionsManager;

		// NSLog(@"%@", self.favoritesDelegate.contents); /* DEBUG LOG */

		// only request predictions of there are favorited stops
		if ([self.stopsDelegate.contents count] > 0) {

			NSMutableArray *requests = [NSMutableArray array];

			// iterate through the stops on screen and create prediction requests from them
			for (NSDictionary *stopItem in self.stopsDelegate.contents) {

				NSString *agencyShortTitle = [stopItem valueForKey:@"agencyShortTitle"];
				NSString *stopTag = [stopItem valueForKey:@"tag"];

				if ([agencyShortTitle isEqual:@"bart"]) {

					PredictionRequest *request = [[PredictionRequest alloc] init];
					request.isMainRoute = NO;
					request.agencyShortTitle = agencyShortTitle;
					request.stopTag = stopTag;

					[requests addObject:request];

				} else

					// iterate through the directions for all the stops to create prediction requests from them
					for (NSDictionary *directionItem in [stopItem objectForKey : @"lines"]) {

						PredictionRequest *request = [[PredictionRequest alloc] init];
						request.stopTag = stopTag;
						request.route = [DataHelper routeWithTag:[directionItem valueForKey:@"routeTag"] inAgencyWithShortTitle:agencyShortTitle];
						request.agencyShortTitle = agencyShortTitle;
						request.isMainRoute = NO;

						[requests addObject:request];
					}
			}
			// request predictions for the stops in the favorites screen
			[NSThread detachNewThreadSelector:@selector(requestPredictionsForRequests:) toTarget:predictionsManager withObject:requests];
			NSLog(@"FavoritesVC: predictions requested"); /* DEBUG LOG */
		}
	}
}

// method called when PredictionsManager returns predictions. set the predictions variable in the favoritestops delegate and reload the tableview
- (void) didReceivePredictions:(NSDictionary *)predictions {

	// only load predictions for the stops screen. trips don't need predictions
	// NSLog(@"FavoritesVC: didReceivePredictions: %d", [predictions count]); /* DEBUG LOG */

	// only return predicitons if they're not an error
	// or if if the table is not editing
	if ( ([predictions objectForKey:@"error"] != nil)||[self.tableView isEditing] ) return;
	// find the index paths of the rows these predictions are for
	NSMutableArray *indexPaths = [NSMutableArray array];

	for (NSString *predictionKey in [predictions allKeys]) {

		Prediction *prediction = [predictions objectForKey:predictionKey];

		NSPredicate *stopFilter = [NSPredicate predicateWithFormat:@"tag == %@", prediction.stopTag];
		NSPredicate *agencyFilter = [NSPredicate predicateWithFormat:@"agencyShortTitle == %@", prediction.agencyShortTitle];

		NSMutableArray *matchingStops = [NSMutableArray arrayWithArray:[self.stopsDelegate.contents filteredArrayUsingPredicate:stopFilter]];
		[matchingStops filterUsingPredicate:agencyFilter];

		for (NSDictionary *stopItem in matchingStops) {

			// NSLog(@"MATCHING STOP ITEM: %@", stopItem); /* DEBUG LOG */

			int rowIndex = [self.stopsDelegate.contents indexOfObject:stopItem];
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];

			// since favorite stops with multiple lines have multiple predictions,
			// only add the index path to the array of index paths to update once
			if (![indexPaths containsObject:indexPath]) [indexPaths addObject:indexPath];
		}
	}
	[self.stopsDelegate.predictions addEntriesFromDictionary:predictions];

	// NSLog(@"FavoritesVC: cells reloaded: %d", [indexPaths count]); /* DEBUG LOG */

	// reload the cells for these predictions
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];

}

// responds to the tap of the favorites segmented control and loads the appropriate favorites (stops or trips)
- (void) tapSegmentedControl {

	// stops
	if (self.segmentedControl.selectedSegmentIndex == 0) {
		self.reloadPredictionsButton.enabled = YES;

		// reload table contents from the favorites.plist file
		[self.stopsDelegate loadFavoritesFile];

		self.tableView.dataSource = self.stopsDelegate;
		self.tableView.delegate = self.stopsDelegate;

		// SETTINGS FOR WHEN THERE ARE NO FAVORITE STOPS
		int numberOfFavorites = [self.stopsDelegate.contents count];

		if (numberOfFavorites == 0) {
			[self.view addSubview:self.noFavoritesMessageView];
			self.navigationItem.rightBarButtonItem.enabled = NO;
		} else if (numberOfFavorites == 1) {
			self.navigationItem.rightBarButtonItem.enabled = NO;
			[self.noFavoritesMessageView removeFromSuperview];
		} else {
			self.navigationItem.rightBarButtonItem.enabled = YES;
			[self.noFavoritesMessageView removeFromSuperview];

		}
		[self requestPredictions];

	}
	// trips
	else if (self.segmentedControl.selectedSegmentIndex == 1) {
		self.reloadPredictionsButton.enabled = NO;
		self.tableView.dataSource = nil;
		self.tableView.delegate = nil;

		[self.noFavoritesMessageView removeFromSuperview];
	}
	[self.tableView reloadData];

	// NSIndexPath *topPath = [NSIndexPath indexPathForRow:0 inSection:0];
	// [tableView scrollToRowAtIndexPath:topPath atScrollPosition: UITableViewScrollPositionNone animated:NO];

}

// loads the stop screen if a favorite stop is selected or a trip screen is a favorite trip is selected
- (void) loadNextViewController:(NSNotification *)note {

	// if a favorite stop was selected
	if (note.name == @"favoriteStopSelected") {

		Stop *stop = (Stop *)note.object;
		NSString *agencyShortTitle = [[DataHelper agencyFromStop:stop] shortTitle];

		if ([agencyShortTitle isEqualToString:@"bart"]) {
			BartStopDetails *bartStopDetails = [[BartStopDetails alloc] init];
			bartStopDetails.stop = (Stop *)note.object;

			[self.navigationController pushViewController:bartStopDetails animated:YES];
		} else {
			NextBusStopDetails *stopDetails = [[NextBusStopDetails alloc] init];
			stopDetails.stop = (Stop *)note.object;

			[self.navigationController pushViewController:stopDetails animated:YES];
		}
	}
}

#pragma mark -
#pragma mark Memory

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload {
	// Release any retained subviews of the main view.

	self.tableView = nil;
	self.reloadPredictionsButton = nil;
	self.editButton = nil;
    self.segmentedControl = nil;
}


@end
