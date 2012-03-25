//
// StopsTVC.m
// BATransit
//
// Created by Ljuba Miljkovic on 11/10/09.
// Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "DataHelper.h"
#import "RowDivider.h"
#import "StopsTVC.h"

@implementation StopsTVC

@synthesize stops, direction, locationManager;

- (void) viewDidLoad {
	[super viewDidLoad];

	// settings
	self.title = [NSString stringWithFormat:@"%@ %@", self.direction.route.tag, self.direction.name];
	NSString *backTitle = [NSString stringWithFormat:@"%@ Stops", self.direction.route.tag];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;

	// tableview settings
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	// setup core location
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

	// this array contains two thing: an array of nearby stops, and an array of the complete set of stops for a direction
	self.stops = [[NSMutableArray alloc] initWithCapacity:2];

	NSNull *nullObject = [[NSNull alloc] init];
	[self.stops addObject:[NSMutableArray arrayWithObject:nullObject]];  // add placeholder nearby "stop" array that will be determined in "viewDidAppear"

	NSArray *sortOrder = (NSArray *)direction.stopOrder;             // the order of stops for this direction
	NSMutableArray *allStops = [[NSMutableArray alloc] initWithCapacity:1];

	// find stop in self.stops and add it to the orderedStops array
	for (NSString *stopTag in sortOrder) {

		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag=%@", stopTag];
		NSSet *temp = [direction.stops filteredSetUsingPredicate:predicate];

		Stop *thisStop = [temp anyObject];

		[allStops addObject:thisStop];
	}
    
	[self.stops addObject:allStops];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.locationManager startUpdatingLocation];

	// setup notification to listen to notifications app delegate
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.locationManager stopUpdatingLocation];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];

}

// turns off location updating
- (void) toggleLocationUpdating:(NSNotification *)note {

	if ([note.name isEqual:UIApplicationWillResignActiveNotification]) {

		NSLog(@"StopsTVC: Location Updating OFF"); /* DEBUG LOG */
		[self.locationManager stopUpdatingLocation];
	} else if ([note.name isEqual:UIApplicationDidBecomeActiveNotification]) {

		NSLog(@"StopsTVC: Location Updating ON"); /* DEBUG LOG */
		[self.locationManager startUpdatingLocation];
	}
}

#pragma mark -
#pragma mark Location

// notify the class when there is a new location update the closest stop can be shown
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	NSLog(@"Interval Time: %f", [newLocation.timestamp timeIntervalSinceNow]); /* DEBUG LOG */

	// display closest stop if the location fix accuracy is valid (non-negative) and within 50m. And that the timestamp is less then 120 seconds old
	if ( (newLocation.horizontalAccuracy >= 0)&&(newLocation.horizontalAccuracy < 200)&&([newLocation.timestamp timeIntervalSinceNow] > -120) ) {

		[self displayClosestStopToLocation:newLocation];

		// don't update location anymore. this will save battery power once an accurate fix has been established.
		[self.locationManager stopUpdatingLocation];

	}
}

// calls the function to calculate the closest stop and displays it in the table view
- (void) displayClosestStopToLocation:(CLLocation *)location {

	NSMutableArray *closestStops = [DataHelper findClosestStopsFromLocation:location amongStops:[stops objectAtIndex:1] count:1];

	// replace the empty "nearby" stop array added in "viewDidLoad"
	[self.stops replaceObjectAtIndex:0 withObject:closestStops];

	[self.tableView reloadData];

}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

}

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return([self.stops count]);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return([[self.stops objectAtIndex:section] count]);
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return(41);

}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

	static NSString *SearchCellIdentifier = @"SearchCell";

	// searching cell
	if ( (section == 0)&&[[[self.stops objectAtIndex:section] objectAtIndex:row] isMemberOfClass:[NSNull class]] ) {

		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];

		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SearchCellIdentifier];
			cell.textLabel.font = [UIFont boldSystemFontOfSize:17];

			cell.textLabel.text = @"Searching...";
			cell.indentationWidth = 23;
			cell.indentationLevel = 1;
			cell.imageView.image = nil;
			cell.accessoryType = UITableViewCellAccessoryNone;

			UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			spinner.center = CGPointMake(16, cell.center.y - 1);
			[spinner startAnimating];
			[cell.contentView addSubview:spinner];
		}
		return(cell);
	}
	// stop cell
	static NSString *StopCellIdentifier = @"StopCell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:StopCellIdentifier];

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:StopCellIdentifier];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
		cell.indentationLevel = 0;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	Stop *currentStop = [[stops objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	NSString *agencyShortTitle = currentStop.agency.shortTitle;

	cell.textLabel.text = currentStop.title;

	// start, end, or mid line stop?
	int stopIndex = [[stops objectAtIndex:1] indexOfObjectIdenticalTo:currentStop];

	if (stopIndex == 0) cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stop-beginning-route-%@.png", agencyShortTitle]];
	else if (stopIndex == [[stops objectAtIndex:1] count] - 1) cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stop-end-route-%@.png", agencyShortTitle]];
	else cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"stop-mid-route-%@.png", agencyShortTitle]];
	return(cell);

}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return(kRowDividerHeight);
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	RowDivider *header = [[RowDivider alloc] initWithFrame:CGRectMake(0, 0, 320, kRowDividerHeight)];

	if (section == 0) header.title = @"Nearest";
	else header.title = @"Stops";
	return(header);
}

// don't allow Placeholder rows to be selectable
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([[[stops objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) return(nil);
	return(indexPath);

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

	NextBusStopDetails *nextBusStopDetails = [[NextBusStopDetails alloc] init];
	nextBusStopDetails.stop = [[stops objectAtIndex:section] objectAtIndex:row];
	nextBusStopDetails.mainDirection = direction;

	[self.navigationController pushViewController:nextBusStopDetails animated:YES];

}

- (void) viewDidUnload {}


@end
