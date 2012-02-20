//
// FavoritesStops.m
// kronos
//
// Created by Ljuba Miljkovic on 4/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FavoriteStops.h"
#import "FavoritesManager.h"

#import "LineRow.h";
#import "StopNameRow.h"

#import "DataHelper.h"
#import "Prediction.h"
#import "kronosAppDelegate.h"

#import "Constants.h"

#define kFavStopNameRowHeight 35
#define kFavLineRowHeight 43
#define kFavLastLineRowHeight 49

@implementation FavoriteStops

@synthesize predictions;

- (id) init {

	if (self = [super init]) {

		predictions = [[NSMutableDictionary alloc] init];
		self.selectedItem = nil;
	}
	return(self);

}

// loads the favorites.plist file into the contents array and restructures it to include the agency for each stop
- (void) loadFavoritesFile {

	self.contents = [[NSMutableArray alloc] initWithArray:[FavoritesManager getFavorites]];

	NSLog(@"FAVORITES: %@", contents); /* DEBUG LOG */

}

// saves the contents dictionary to the favorites file. useful when a user reorders the stops
- (void) saveContentsToFavoritesFile {

	[FavoritesManager saveFavorites:contents];

}

#pragma mark Table view methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	int numberOfLines = [[[contents objectAtIndex:indexPath.row] objectForKey:@"lines"] count];

	int height = kFavStopNameRowHeight + (numberOfLines - 1) * kFavLineRowHeight + kFavLastLineRowHeight;

	return(height);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return(1);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return([contents count]);

}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.showsReorderControl = YES;
	}

	for (UIView *view in [cell.contentView subviews]) [view removeFromSuperview];
	int row = indexPath.row;

	// contains all the info about this favorite stop
	NSDictionary *stopItem = [contents objectAtIndex:row];

	NSString *agencyShortTitle = [stopItem objectForKey:@"agencyShortTitle"];
	NSString *stopName = [stopItem objectForKey:@"title"];
	NSString *stopTag = [stopItem objectForKey:@"tag"];

	// CREATE THE STOP AND LINES ROWS

	StopNameRow *stopNameRow = [[StopNameRow alloc] initWithStopName:stopName agencyShortTitle:agencyShortTitle];

	NSArray *lines = [stopItem objectForKey:@"lines"];

	NSRange range;
	range.length = [lines count];

	// create a line row for each line in the favorite
	for (NSDictionary *lineItem in lines) {

		NSString *predictionKey;

		range.location = [lines indexOfObject:lineItem];

		NSArray *colors = nil;

		if ([agencyShortTitle isEqual:@"bart"]) {

			NSString *destinationStopTag = [lineItem objectForKey:@"destinationStopTag"];

			Destination *destination = [DataHelper destinationForBARTStopTag:stopTag toStopTag:destinationStopTag];

			colors = destination.colors;

			predictionKey = [PredictionsManager predictionKeyFromAgencyShortTitle:agencyShortTitle routeTag:destinationStopTag stopTag:stopTag];

		} else {

			NSString *routeTag = [lineItem objectForKey:@"routeTag"];
			predictionKey = [PredictionsManager predictionKeyFromAgencyShortTitle:agencyShortTitle routeTag:routeTag stopTag:stopTag];
		}
		LineRow *lineRow = [[LineRow alloc] initWithLineItem:lineItem withColors:colors inRange:range];
		[lineRow setCellStatus:kCellStatusSpinner];

		// GET PREDICTIONS FROM PREDICTIONS ARRAY

		// NSLog(@"ROW KEY: %@", predictionKey); /* DEBUG LOG */

		Prediction *prediction = [predictions objectForKey:predictionKey];

		if (prediction != nil) {

			[lineRow setCellStatus:kCellStatusDefault];

			NSMutableDictionary *arrivalsDict = prediction.arrivals;

			NSString *arrivalsKey;
			NSArray *arrivals = [[NSArray alloc] init];

			if ([agencyShortTitle isEqual:@"bart"]) {

				NSString *destinationStopTag = [lineItem objectForKey:@"destinationStopTag"];
				arrivalsKey = destinationStopTag;

				arrivals = [arrivalsDict objectForKey:arrivalsKey];

				if ([arrivals count] == 0) lineRow.cellStatus = kCellStatusPredictionFail;
			} else {

				// find the dirTags that match the name and title of this direction
				NSString *dirName = [lineItem objectForKey:@"name"];
				NSString *dirTitle = [lineItem objectForKey:@"title"];
				NSString *routeTag = [lineItem objectForKey:@"routeTag"];

				NSArray *dirTags = [DataHelper directionTagsThatMatchDirectionName:dirName directionTitle:dirTitle routeTag:routeTag forAgencyWithShortTitle:agencyShortTitle];

				NSLog(@"%@", dirTags); /* DEBUG LOG */

				for (NSString *dirTag in dirTags) {

					NSArray *allArrivalsKeys = [arrivalsDict allKeys];

					for (NSString *arrivalsKey in allArrivalsKeys)

						if ([arrivalsKey isEqual:dirTag]) {

							arrivals = [arrivalsDict objectForKey:arrivalsKey];

							break;
						}
				}
			}

			if ([arrivals count] == 0) lineRow.cellStatus = kCellStatusPredictionFail;
			[lineRow setArrivals:arrivals];
		}
		[cell.contentView addSubview:lineRow];
		[lineRow release];

	}
	[cell.contentView addSubview:stopNameRow];

	// NSLog(@"%@", stopName); /* DEBUG LOG */
	// NSLog(@"%@", [cell.contentView subviews]); /* DEBUG LOG */

	return(cell);
}

#pragma mark -
#pragma mark Table Editing

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

	return(UITableViewCellEditingStyleNone);

}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

	// rearrange contents to match the new row arrangement

	int fromRowIndex = fromIndexPath.row;
	int toRowIndex = toIndexPath.row;

	id fromRow = [[contents objectAtIndex:fromRowIndex] retain];

	[contents removeObjectAtIndex:fromRowIndex];
	[contents insertObject:fromRow atIndex:toRowIndex];

	[fromRow release];

}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {

	return(NO);
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

	return(YES);

}

#pragma mark -
#pragma mark Table Selection

// when a user taps a cell (fav stop) send a note to the FavoritesVC with the stop to load
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	// the tapped stop item
	NSDictionary *stopItem = [self.contents objectAtIndex:indexPath.row];
	NSString *stopTag = [stopItem valueForKey:@"tag"];
	NSString *agencyShortTitle = [stopItem valueForKey:@"agencyShortTitle"];
	NSData *stopURIData = [stopItem objectForKey:@"stopURIData"];

	Stop *tappedStop;

	// if for some reason, the objectID isn't pointing to anything real, load the stop based on the stopTag and agencyShortTitle;
	if (stopURIData == nil)	tappedStop = [DataHelper stopWithTag:stopTag inAgencyWithShortTitle:agencyShortTitle];

	else {

		NSURL *stopURI = [NSKeyedUnarchiver unarchiveObjectWithData:stopURIData];

		kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSPersistentStoreCoordinator *persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
		NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

		NSManagedObjectID *stopID = [persistentStoreCoordinator managedObjectIDForURIRepresentation:stopURI];

		tappedStop = (Stop *)[managedObjectContext objectWithID:stopID];

		// if for some reason, the returned stop doesn't have the same tag as the favorite stop, find it the hard way
		if (![tappedStop.tag isEqual:stopTag]) tappedStop = [DataHelper stopWithTag:stopTag inAgencyWithShortTitle:agencyShortTitle];
	}
	NSLog(@"TAPPED STOP: %@", tappedStop.title);

	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	// send a notification to the FavoritesVC to load the appropriate stop screen
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"favoriteStopSelected" object:tappedStop];

}

- (void) dealloc {

	[predictions release];

	[super dealloc];        // selectedItem and contents are released in super
}

@end
