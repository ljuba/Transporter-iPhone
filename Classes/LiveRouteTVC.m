//
// LiveRouteTVC.m
// kronos
//
// Created by Ljuba Miljkovic on 3/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "LiveRouteTVC.h"
#import "Prediction.h"
#import "Route.h"
#import "Stop.h"
#import "kronosAppDelegate.h"

#define kLiveRouteNotOnBusMessage @"Once on board, tap a stop for your ETA"
#define kLiveRouteOnBusMessage @"Tap an upcoming stop to see your ETA"
#define kLiveRouteBARTMessage @"BART does not support ETA predictions"
#define kLiveRouteFindingLocation @"Finding your location..."
// @"You do not appear to be on this line."

@implementation LiveRouteTVC

@synthesize stops, userMarker, locationManager, direction, _tableView, startingStop, scrollStop, label, locationFixTimeoutTimer, locationAccuracy, vehicleFetcher;
@synthesize predictions, tappedStop, vehicleID, isBART, savedNextStop, savedPreviousStop;

- (void) viewDidLoad {
	[super viewDidLoad];

	// general settings
	if ([self.direction.route.agency.shortTitle isEqual:@"bart"]) {
		self.title = [NSString stringWithFormat:@"%@ Line", self.direction.title];
		self.locationAccuracy = 600;
		self.isBART = YES;
	} else {
		self.title = [NSString stringWithFormat:@"%@ %@", self.direction.route.tag, self.direction.name];
		self.locationAccuracy = 200;
		self.isBART = NO;
	}
	// setup refresh predictions button
	UIBarButtonItem *findLocationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"] style:UIBarButtonItemStylePlain target:self action:@selector(findLocation)];
	findLocationButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = findLocationButton;

	// setup for saving state
	[DataHelper saveDirectionIDInUserDefaults:self.direction forKey:@"liveRouteDirectionURIData"];

	// tableView setting
	self._tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self._tableView.delegate = self;
	self._tableView.dataSource = self;

	// SETUP VEHICLE FETCHER & PREDICTIONS
	self.vehicleFetcher = [[VehicleFetcher alloc] init];
	self.predictions = [[NSMutableDictionary alloc] init];

	// add userMarker view to the tableView;
	self.userMarker = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.userMarker setImage:[UIImage imageNamed:@"TrackingDot.png"] forState:UIControlStateNormal];
	[self.userMarker setImage:[UIImage imageNamed:@"TrackingDotPressed.png"] forState:UIControlStateHighlighted];
	self.userMarker.hidden = YES;
	[self._tableView addSubview:self.userMarker];

	// setup core location
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	self.savedNextStop = nil;
	self.savedPreviousStop = nil;

	self.stops = (NSMutableArray *)[self.direction.stops allObjects];

	NSArray *sortOrder = (NSArray *)self.direction.stopOrder;             // the order of stops for this direction
	NSMutableArray *orderedStops = [[NSMutableArray alloc] init];

	// find stop in self.stops and add it to the orderedStops array
	for (NSString *stopTag in sortOrder) {

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag=%@", stopTag];
		NSSet *temp = [self.direction.stops filteredSetUsingPredicate:predicate];

		Stop *thisStop = [temp anyObject];

		[orderedStops addObject:thisStop];
	}
	self.stops = orderedStops;
}

- (void) viewWillDisappear:(BOOL)animated {

	[super viewWillDisappear:animated];

	self.locationManager.delegate = nil;
	[self.locationManager stopUpdatingLocation];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];

}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	self.scrollStop = self.startingStop;

	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];

	self.label.text = kLiveRouteFindingLocation;

	// stop updating location after 40 seconds if you Cannot find anything
	self.locationFixTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:40.0 target:self selector:@selector(giveupLocationFix) userInfo:nil repeats:NO];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationDidBecomeActiveNotification object:nil];

	[self scrollToStopAnimated:YES];

}

#pragma mark -
#pragma mark Prediction Methods

// sends a request for vehicles serving this direction
- (void) fetchVehicles {

	self.label.text = @"Locating transit vehicles...";

	// request trips
	[self.vehicleFetcher performSelectorInBackground:@selector(fetchVehiclesForDirection:) withObject:self.direction];

}

// recieves the vehicles for this direction from the vehicleFetcher and finds the closest one
- (void) didReceiveVehicles:(NSMutableArray *)vehicles {

	if ([vehicles count] == 0) {
		NSLog(@"LIVEROUTE: NO VEHICLES FOUND"); /* DEBUG LOG */

		self.label.text = kLiveRouteNotOnBusMessage;
		return;
	}
	// FIND MATCHING VEHICLE WITHIN 1000m meter radius
	self.vehicleID = [self matchingVehicleID:vehicles];

	// IF THE CLOSEST VEHICLE IS TOO FAR AWAY, TELL THE USER THEY'RE NOT ON A BUS
	if (self.vehicleID == nil) {

		NSLog(@"LIVEROUTE: NO MATCHING VEHILES FOUND"); /* DEBUG LOG */

		self.label.text = kLiveRouteNotOnBusMessage;
		return;
	}
	self.label.text = kLiveRouteOnBusMessage;

	[self._tableView reloadData];

	// NSLog(@"VEHICLES: %@", vehicles); /* DEBUG LOG */
	NSLog(@"DESIRED VEHICLE: %@", self.vehicleID); /* DEBUG LOG */

}

// return the vehicle id that matches the user location
- (NSString *) matchingVehicleID:(NSMutableArray *)vehicles {

	CLLocation *userLocation = self.locationManager.location;

	NSDictionary *closestVehicle = nil;
	double closestVehicleDistance = 999999999;               // init so that the first stop looked at will be the closest for sure

	for (NSDictionary *vehicle in vehicles) {

		CLLocation *vehicleLocation = [[CLLocation alloc]
					       initWithLatitude:[[vehicle objectForKey:@"lat"] doubleValue]
					       longitude:[[vehicle objectForKey:@"lon"] doubleValue]];

		double vehicleDistance = [vehicleLocation distanceFromLocation:userLocation];


		// if this stop is closer than the last one tried, mark it as the closest
		if (vehicleDistance < closestVehicleDistance) {

			closestVehicle = vehicle;
			closestVehicleDistance = vehicleDistance;

		}
	}

	// CHECK IF CLOSEST VEHICLE IS CLOSE ENOUGH
	if (closestVehicleDistance < 600) return([closestVehicle objectForKey:@"id"]);
	else return(nil);
}

- (void) fetchPredictions {

	self.label.text = @"Calculating arrival time...";

	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	PredictionsManager *predictionsManager = appDelegate.predictionsManager;

	NSMutableArray *requests = [NSMutableArray array];

	PredictionRequest *request = [[PredictionRequest alloc] init];

	request.agencyShortTitle = self.direction.route.agency.shortTitle;
	request.route = self.direction.route;
	request.stopTag = self.tappedStop.tag;
	request.isMainRoute = NO;

	[requests addObject:request];

	// request predictions for the stops in the favorites screen
	[NSThread detachNewThreadSelector:@selector(requestPredictionsForRequests:) toTarget:predictionsManager withObject:requests];

	// [predictionsManager requestPredictionsForRequests:requests];
	NSLog(@"LiveRoute: predictions requested"); /* DEBUG LOG */
	NSLog(@"%@", requests); /* DEBUG LOG */

}

- (void) didReceivePredictions:(NSMutableDictionary *)_predictions {

	self.label.text = kLiveRouteOnBusMessage;

	NSString *predictionKey = [PredictionsManager predictionKeyFromAgencyShortTitle:self.direction.route.agency.shortTitle routeTag:self.direction.route.tag stopTag:self.tappedStop.tag];

	// prevents stray predicion returns from popping up an alert dialog
	if ([_predictions objectForKey:predictionKey] == nil) return;
	[self.predictions addEntriesFromDictionary:_predictions];

	Prediction *prediction = [self.predictions objectForKey:predictionKey];

	// NSLog(@"ARRIVALS: %@", prediction.arrivals); /* DEBUG LOG */

	NSPredicate *vehicleFilter = [NSPredicate predicateWithFormat:@"vehicle == %@", self.vehicleID];

	NSMutableArray *filteredArrivals = [NSMutableArray array];

	for (NSArray *directionArrivals in [prediction.arrivals allValues])

		for (NSDictionary * arrival in directionArrivals) [filteredArrivals addObject:arrival];
	[filteredArrivals filterUsingPredicate:vehicleFilter];

	// IF THERE ARE NO ARRIVALS FOR THIS VEHICE AT THIS STOP
	if ([filteredArrivals count] == 0) {
		// there are no arrivals preditions at this stop for the vehicle we want
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
				      message:@"No ETA available for this stop"
				      delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

		[self._tableView deselectRowAtIndexPath:[self._tableView indexPathForSelectedRow] animated:YES];

		[alert show];

		return;

	}
	// SHOW ETA DIALOG BOX
	NSLog(@"VEHICLE ID: %@", self.vehicleID); /* DEBUG LOG */
	NSLog(@"FILTERED ARRIVALS: %@", filteredArrivals); /* DEBUG LOG */

	NSDictionary *arrival = [filteredArrivals objectAtIndex:0];
	int minutes = [[arrival objectForKey:@"minutes"] intValue];

	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:minutes * 60];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setPMSymbol:@"pm"];
	[dateFormatter setAMSymbol:@"am"];

	NSString *duration = [NSString stringWithFormat:@"%d", minutes];
	NSString *message = [NSString stringWithFormat:@"Estimated arrival in \n%@ minutes (%@)", duration, [dateFormatter stringFromDate:date]];


	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.tappedStop.title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

	[self._tableView deselectRowAtIndexPath:[self._tableView indexPathForSelectedRow] animated:YES];

	[alert show];
}

#pragma mark -
#pragma mark Location Methods

// activated when the locationFixTimeoutTimer is fired
- (void) giveupLocationFix {

	[self.locationManager stopUpdatingLocation];
	self.label.text = @"Cannot find your location";
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

// responds to tap of location button
- (void) findLocation {

	[self scrollToStopAnimated:YES];

	[self.locationManager startUpdatingLocation];

	self.label.text = kLiveRouteFindingLocation;  // reset message
	self.navigationItem.rightBarButtonItem.enabled = NO;

	if (!self.isBART) [self fetchVehicles];
	self.locationFixTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:40.0 target:self selector:@selector(giveupLocationFix) userInfo:nil repeats:NO];
}

// turns off location updating
- (void) toggleLocationUpdating:(NSNotification *)note {

	if ([note.name isEqual:UIApplicationWillResignActiveNotification]) {

		NSLog(@"LiveRoute: Location Updating OFF"); /* DEBUG LOG */
		[self.locationManager stopUpdatingLocation];
	} else if ([note.name isEqual:UIApplicationDidBecomeActiveNotification]) {

		NSLog(@"LiveRoute: Location Updating ON"); /* DEBUG LOG */
		[self findLocation];

	}
}

// scroll to the stop immediately behind you
- (void) scrollToStopAnimated:(BOOL)animated {

	NSLog(@"SCROLL TO STOP: %@", self.scrollStop.title); /* DEBUG LOG */

	[self._tableView reloadData];        // must reload data when you scroll to a stop the first time
	[self._tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.stops indexOfObject:self.scrollStop] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];

}

// update location of user every time a good new location comes in
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	// we need good location fixes for both old and new locations
	// don't update location if either location fix accuracy is invalid (negative) or > 50m. Or if the timestamp is more then 120 seconds old
	if ( (newLocation == nil)||(oldLocation == nil)||
	     (newLocation.horizontalAccuracy < 0)||(newLocation.horizontalAccuracy > self.locationAccuracy)||([newLocation.timestamp timeIntervalSinceNow] < -120)||
	     oldLocation.horizontalAccuracy < 0||oldLocation.horizontalAccuracy > self.locationAccuracy||([oldLocation.timestamp timeIntervalSinceNow] < -120) )
		// NSLog(@"%@", @"BAD FIX"); /* DEBUG LOG */
		// NSLog(@"Old: Accuracy:%f, Time:%f", oldLocation.horizontalAccuracy,[oldLocation.timestamp timeIntervalSinceNow] ); /* DEBUG LOG */
		// NSLog(@"New: Accuracy:%f, Time:%f", newLocation.horizontalAccuracy,[newLocation.timestamp timeIntervalSinceNow] ); /* DEBUG LOG */
		return;
	// NSLog(@"%@", @"FIX GOOD"); /* DEBUG LOG */

	// turn of the timer that would tell the user that we Cannot find their position
	[self.locationFixTimeoutTimer invalidate];

	[self positionUserMarkerToNewLocation:newLocation fromLocation:oldLocation];

}

// calculate the position of the user marker
- (void) positionUserMarkerToNewLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	// FIND CLOSEST STOP

	Stop *closestStop = nil;
	double closestStopDistance = 999999999;          // init so that the first stop looked at will be the closest for sure

	for (Stop *stop in self.stops) {

		double stopDistance = [newLocation distanceFromLocation:[DataHelper locationOfStop:stop]];

		// if this stop is closer than the last one tried, mark it as the closest
		if (stopDistance < closestStopDistance) {

			closestStop = stop;
			closestStopDistance = stopDistance;

		}
	}
	// NSLog(@"CLOSEST STOP %@", closestStop); /* DEBUG LOG */

	// DETERMINE IF YOU'RE ACTUALLY ON THE LINE
	// Given the closest stop B, previous stop A and next stop C
	// You are not on the line if you are simultaneously further from A than B is && futher from C than B is

	int closestStopIndex = [self.stops indexOfObjectIdenticalTo:closestStop];

	Stop *stopA = nil;
	Stop *stopC = nil;

	// if the closest stop is the first stop in the direction...
	if (closestStopIndex == 0) {

		// there is no stopA
		stopC = [self.stops objectAtIndex:closestStopIndex + 1];

		// if you are further from the closest stop (B) than the next stop in the line (stopC), you are not on the line
		if ([newLocation distanceFromLocation:[DataHelper locationOfStop:closestStop]] > [[DataHelper locationOfStop:stopC] distanceFromLocation:[DataHelper locationOfStop:closestStop]]) {
			NSLog(@"TOO FAR FROM START OF LINE: %@", self.direction.route.tag); /* DEBUG LOG */
			self.label.text = @"You don't appear to be on this line.";
			self.navigationItem.rightBarButtonItem.enabled = YES;
			[self.locationManager stopUpdatingLocation];
			return;
		}
	}
	// if the closest stop is the last stop in the direction...
	else if (closestStopIndex == [self.stops count] - 1) {

		// there is no stopC
		stopA = [self.stops objectAtIndex:closestStopIndex - 1];

		// if you are further from the closest stop (B) than the previous stop in the line (stopA), you are not on the line
		if ([newLocation distanceFromLocation:[DataHelper locationOfStop:closestStop]] > [[DataHelper locationOfStop:stopA] distanceFromLocation:[DataHelper locationOfStop:closestStop]]) {
			NSLog(@"TOO FAR FROM END OF LINE: %@", self.direction.route.tag); /* DEBUG LOG */
			self.label.text = @"You don't appear to be on this line.";
			self.navigationItem.rightBarButtonItem.enabled = YES;
			[self.locationManager stopUpdatingLocation];
			return;
		}
	}
	// now that we've handled the edge cases, check if you're on the line if the closest stop is not the first or last stop in the line
	else {

		stopA = [self.stops objectAtIndex:closestStopIndex - 1];
		stopC = [self.stops objectAtIndex:closestStopIndex + 1];

		NSLog(@"Stop B: %@", closestStop.title); /* DEBUG LOG */
		NSLog(@"Stop A: %@", stopA.title); /* DEBUG LOG */
		NSLog(@"Stop C: %@", stopC.title); /* DEBUG LOG */

		// distance of stopA to stopB (closest stopB) and distance from stopA to user location, respectively
		double AB = [[DataHelper locationOfStop:stopA] distanceFromLocation:[DataHelper locationOfStop:closestStop]];
		double AX = [[DataHelper locationOfStop:stopA] distanceFromLocation:newLocation];

		// distance of stopA to stopB (closest stopB) and distance from stopC to user location, respectively
		double CB = [[DataHelper locationOfStop:stopC] distanceFromLocation:[DataHelper locationOfStop:closestStop]];
		double CX = [[DataHelper locationOfStop:stopC] distanceFromLocation:newLocation];

		// NSLog(@"AB %f < AX %f", AB, AX); /* DEBUG LOG */
		// NSLog(@"CB %f < CX %f", CB, CX); /* DEBUG LOG */

		if ( (AX > AB)&&(CX > CB) ) {
			NSLog(@"TOO FAR FROM LINE: %@", self.direction.route.tag); /* DEBUG LOG */
			self.label.text = @"You don't appear to be on this line.";
			self.navigationItem.rightBarButtonItem.enabled = YES;
			[self.locationManager stopUpdatingLocation];
			return;
		}
	}

	if ([newLocation distanceFromLocation:[DataHelper locationOfStop:closestStop]] > self.locationAccuracy * 4) {
		NSLog(@"%@", @"LIVEROUTE: TOO FAR AWAY FROM ANY STOP"); /* DEBUG LOG */
		self.label.text = @"You don't appear to be on this line.";
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[self.locationManager stopUpdatingLocation];
		return;
	}
	// NSLog(@"LIVEROUTE: Closest Stop: %@", closestStop.title); /* DEBUG LOG */

	// are you closer to the current closest stop than you were from the previous location fix?
	// if you're closer now, you're moving towards it (and away from the previous stop). if not, you're moving away and towards the next stop

	Stop *nextStop;
	Stop *previousStop;

	// the distance from the new location fix to the current closest stops
	double newDistanceToClosestStop = [newLocation distanceFromLocation:[DataHelper locationOfStop:closestStop]];
	// the distance from the old location fix to the CURRENT cloation stop (not the previous closest stop)
	double oldDistanceToClosestStop = [oldLocation distanceFromLocation:[DataHelper locationOfStop:closestStop]];

	// if you're moving away from the closest stop...
	if (newDistanceToClosestStop > oldDistanceToClosestStop) {
		previousStop = closestStop;
		nextStop = [self.stops objectAtIndex:[self.stops indexOfObject:closestStop] + 1];

		self.savedNextStop = nextStop;
		self.savedPreviousStop = previousStop;

		self.scrollStop = previousStop;
	}
	// if you're moving towards the closest stop...
	else if (newDistanceToClosestStop < oldDistanceToClosestStop) {
		previousStop = [self.stops objectAtIndex:[self.stops indexOfObject:closestStop] - 1];
		nextStop = closestStop;

		self.savedNextStop = nextStop;
		self.savedPreviousStop = previousStop;

		self.scrollStop = previousStop;
	}
	// you haven't moved, used the saved next/previous stops from the last time they were known
	else {

		previousStop = self.savedPreviousStop;
		nextStop = self.savedNextStop;

		if ( (previousStop == nil)||(nextStop == nil) ) {
			previousStop = closestStop;

			int prevStopIndex = [self.stops indexOfObject:previousStop];
			nextStop = [self.stops objectAtIndex:prevStopIndex + 1];

		}
		self.scrollStop = previousStop;
	}
	// NSLog(@"LIVEROUTE: Previous Stop: %@", previousStop.title); /* DEBUG LOG */
	// NSLog(@"LIVEROUTE: Next Stop: %@", nextStop.title); /* DEBUG LOG */

	// NOW THAT WE KNOW WHICH STOPS ARE ON EITHER SIDE OF US, WHERE (EXACTLY) ARE YOU IN BETWEEN THEM?

	// the distance from the new location fix to the NEXT stop
	double distanceToNextStop = [newLocation distanceFromLocation:[DataHelper locationOfStop:nextStop]];
	// the distance from the old location fix to the PREVIOUS stop
	double distanceToPreviousStop = [newLocation distanceFromLocation:[DataHelper locationOfStop:previousStop]];

	// what fraction of the distance between the previous and next stop have you traveled: (e.g. 0.5 = half way)
	double fractionalDistanceFromPreviousStop = distanceToPreviousStop / (distanceToNextStop + distanceToPreviousStop);

	// NSLog(@"LIVEROUTE: Fractional Distance: %f", fractionalDistanceFromPreviousStop); /* DEBUG LOG */

	// calculate the y position of the user location based on the index of the prevous stop, row height, and fractionalDistanceFromPreviousStop
	double yPosition = kLiveRouteRowHeight * ([self.stops indexOfObject:previousStop] + fractionalDistanceFromPreviousStop) + kLiveRouteRowHeight / 2;

	// NSLog(@"LIVEROUTE: yPosition: %f", yPosition); /* DEBUG LOG */

	// set marker position
	self.userMarker.hidden = NO;
	self.userMarker.frame = CGRectMake(0, 0, 21, 23);
	self.userMarker.center = CGPointMake(12, yPosition);

	[self._tableView setNeedsDisplay];

	// only scroll to the current stop the first time the userMarker is placed
	// only fetch vehicles onces
	if (self.label.text == kLiveRouteFindingLocation) {
		[self scrollToStopAnimated:YES];

		if (!self.isBART) [self fetchVehicles];
		else self.label.text = kLiveRouteBARTMessage;
	}
	// enable button for scrolling to current location
	self.navigationItem.rightBarButtonItem.enabled = YES;

}

#pragma mark Table view methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	return(kLiveRouteRowHeight);

}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return(1);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return([self.stops count]);
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger row = [indexPath row];

	static NSString *cellIdentifier = @"CellIdentifier";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	}
	Stop *currentStop = [self.stops objectAtIndex:row];
	NSString *agencyShortTitle = currentStop.agency.shortTitle;

	cell.textLabel.text = currentStop.title;

	// only show cell highlighting when you are on the route
	if (self.vehicleID != nil) cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	else cell.selectionStyle = UITableViewCellSelectionStyleNone;
	// start, end, or mid line stop?
	int stopIndex = [self.stops indexOfObjectIdenticalTo:currentStop];

	if (stopIndex == 0) cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stop-beginning-route-%@.png", agencyShortTitle]];
	else if (stopIndex == [self.stops count] - 1) cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stop-end-route-%@.png", agencyShortTitle]];
	else cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stop-mid-route-%@.png", agencyShortTitle]];
	return(cell);

}

// Only allow stops to be selected if you are on the route
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if ( (self.vehicleID != nil)&&!self.isBART ) {

		int tappedRowIndex = indexPath.row;

		// scrollStop is the stop behind you. dont' allow selection of this stop or any before it.
		int scrollStopIndex = [self.stops indexOfObject:self.scrollStop];

		if (tappedRowIndex <= scrollStopIndex) {

			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This stop is behind you" message:@"Cannot calculate ETA for\nstops you've passed." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

			[alert show];

			return(nil);
		}
		return(indexPath);
	} else return(nil);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	int row = indexPath.row;
	self.tappedStop = [self.stops objectAtIndex:row];

	[self fetchPredictions];

}

- (void) viewDidUnload {
	self.label = nil;
	self._tableView = nil;
    
    self.locationManager.delegate = nil;
}


@end
