//
// bartDelegate.m
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "DataHelper.h"
#import "Direction.h"
#import "RowDivider.h"
#import "bartDelegate.h"

// store the closest stop in a static varible so it can be accessed even after you switch agencies in the LinesVC
static NSMutableArray *closestStops;

@implementation bartDelegate

// store the closest stop in a static varible so it can be accessed even after you switch agencies in the LinesVC
+ (NSMutableArray *) closestStops {

	return(closestStops);

}

// store the closest stop in a static varible so it can be accessed even after you switch agencies in the LinesVC
+ (void) setClosestStops:(NSMutableArray *)_closestStops {

	if (closestStops != _closestStops) {
		closestStops = [_closestStops copy];
	}
}

// initializes the formatting of the sf muni lines in the table
- (id) initWithAgency:(Agency *)agency {

	if (self = [super init])
		// sets the contents variable to the routes in this agency
		[self setContentsForBartAgency:agency];
	return(self);
}

// creates the contents array with an alphabetical listing of bart stops
- (void) setContentsForBartAgency:(Agency *)bartAgency {

	NSMutableArray *allStops = [[NSMutableArray alloc] init];

	// add the stops from 1 direction from each route (the stops are the same for each direction of the same route)
	// don't add stops that have already been added
	for (Route *route in bartAgency.routes) {

		Direction *direction = [route.directions anyObject];

		for (Stop *stop in direction.stops)

			if (![allStops containsObject:stop]) [allStops addObject:stop];
	}
	NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[allStops sortUsingDescriptors:[NSArray arrayWithObject:sorter]];


	// the first element will be the closest stop

	if ([closestStops count] != 0) {
		NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:closestStops, allStops, nil];
		self.contents = array;
	} else {
		NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[NSMutableArray arrayWithObject:[NSNull null]], allStops, nil];
		self.contents = array;
	}

}

#pragma mark -
#pragma mark Location

// notify the class when there is a new location update the closest stop can be shown
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	NSLog(@"Interval Time: %f", [newLocation.timestamp timeIntervalSinceNow]); /* DEBUG LOG */

	// display closest stop if the location fix accuracy is valid (non-negative) and within 500m. And that the timestamp is less then 120 seconds old
	// and if there aren't alredy closest stops
	if ( (newLocation.horizontalAccuracy >= 0)&&(newLocation.horizontalAccuracy < 1000)&&([newLocation.timestamp timeIntervalSinceNow] > -120)
	     &&(closestStops == nil) ) {

		[self displayClosestStopToLocation:newLocation];

		// don't update location anymore. this will save battery power once an accurate fix has been established.
		[manager stopUpdatingLocation];

	}
}

// calls the function to calculate the closest stop and displays it in the table view
- (void) displayClosestStopToLocation:(CLLocation *)location {

	closestStops = [DataHelper findClosestStopsFromLocation:location amongStops:[contents objectAtIndex:1] count:2];

	// replace the empty "nearby" stop array added in "viewDidLoad"
	[contents replaceObjectAtIndex:0 withObject:closestStops];

	// tell LinesVC to reload the table data
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"reloadSection0" object:nil];

}

#pragma mark -
#pragma mark Table view methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	return(40);

}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return([contents count]);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return([[contents objectAtIndex:section] count]);
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell.indentationLevel = 0;

	// remove spinner for every new cell
	for (UIView *view in cell.contentView.subviews)	[view removeFromSuperview];

	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	int row = indexPath.row;
	int section = indexPath.section;

	cell.textLabel.font = [UIFont boldSystemFontOfSize:19];

	// check if item is a placeholder or a real stop
	if ([[[self.contents objectAtIndex:section] objectAtIndex:row] isMemberOfClass:[NSNull class]]) {
		cell.textLabel.text = @"Searching...";
		cell.indentationWidth = 23;
		cell.indentationLevel = 1;
		cell.imageView.image = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;

		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		spinner.center = CGPointMake(16, 18);
		[spinner startAnimating];
		[cell.contentView addSubview:spinner];

		return(cell);
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = [[[contents objectAtIndex:section] objectAtIndex:row] title];

	return(cell);
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return(kRowDividerHeight);
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	RowDivider *header = [[RowDivider alloc] initWithFrame:CGRectMake(0, 0, 320, kRowDividerHeight)];

	if (section == 0) header.title = @"Nearest Stops";
	else header.title = @"Stops A-Z";
	return(header);
}

// don't allow Placeholder rows to be selectable
- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([[[contents objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[NSNull class]]) return(nil);
	return(indexPath);

}

// send message to LinesVC that a BART stop was selected
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

	NSLog(@"bartDelegate: %@", @"Stop Tapped"); /* DEBUG LOG */

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"stopSelected" object:[[contents objectAtIndex:section] objectAtIndex:row]];

	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];

}

#pragma mark -
#pragma mark Memory


@end
