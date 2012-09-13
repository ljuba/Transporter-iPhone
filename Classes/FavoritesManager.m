//
// FavoritesManager.m
// kronos
//
// Created by Ljuba Miljkovic on 3/21/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "Destination.h"
#import "FavoritesManager.h"
#import <CoreData/CoreData.h>

@implementation FavoritesManager

+ (void) saveFavorites:(NSArray *)contents {

	// setup favorites file information
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *favoritesPath = [documentsDirectory stringByAppendingPathComponent:@"favorites.plist"];

	[contents writeToFile:favoritesPath atomically:YES];


}

+ (void) checkExistanceOfFavorites {


	NSArray *favorites = [self getFavorites];
	NSMutableArray *newFavorites = [NSMutableArray array];

	BOOL favoritesChanged = NO;

	for (NSDictionary *favorite in favorites) {

		// find stop/agency
		NSString *agencyShortTitle = [favorite valueForKey:@"agencyShortTitle"];
		Agency *agency = [DataHelper agencyWithShortTitle:agencyShortTitle];

		NSString *stopTag = [favorite valueForKey:@"tag"];

		Stop *stop = [DataHelper stopWithTag:stopTag inAgency:agency];

		// if the stop exists, check the lines. otherwise the favorite is discarded
		if (stop != nil) {

			NSArray *lines = [favorite objectForKey:@"lines"];
			NSMutableArray *newLines = [NSMutableArray array];

			for (NSDictionary *line in lines) {

				NSString *routeTag = [line valueForKey:@"routeTag"];
				Route *route = [DataHelper routeWithTag:routeTag inAgency:agency];

				BOOL addLine = YES;
				NSString *directionName = nil;
				NSString *directionTitle = nil;

				NSArray *matchingDirTags = [line objectForKey:@"matchingDirTags"];

				for (NSString *dirTag in matchingDirTags) {

					Direction *direction = [DataHelper directionWithTag:dirTag inRoute:route];

					if (direction == nil) {

						addLine = NO;
						favoritesChanged = YES;

					} else {
						directionName = direction.name;
						directionTitle = direction.title;
					}
				}

				// of all the matching dirTags exist, add the line back, otherwise, don't
				if (addLine) {

					// little changes
					[line setValue:route.sortOrder forKey:@"routeSortOrder"];
					[line setValue:directionName forKey:@"name"];
					[line setValue:directionTitle forKey:@"title"];

					[newLines addObject:line];
				}
			}

			// if there are remaining lines and the stop isn't nil, add the stop
			if ([newLines count] > 0) {

				// set the newLines for the favorite
				[favorite setValue:newLines forKey:@"lines"];

				// set the stop title and ID
				[favorite setValue:stop.title forKey:@"title"];

				NSURL *stopURI = [[stop objectID] URIRepresentation];
				NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:stopURI];
				[favorite setValue:uriData forKey:@"stopURIData"];

				[newFavorites addObject:favorite];

			}
		} else favoritesChanged = YES;
	}

	if (favoritesChanged) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
				      message:@"Due to transit service changes, some of your favorite stops/lines have been removed."
				      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
	// set the new favorites as favorites
	[self saveFavorites:newFavorites];
}

+ (BOOL) isFavoriteStop:(Stop *)stop forLine:(id)line {

	Direction *direction = nil;
	Destination *destination = nil;

	if ([line isMemberOfClass:[Direction class]]) direction = (Direction *)line;
	else destination = (Destination *)line;
	NSArray *favoriteStops = [[NSArray alloc] initWithArray:[self getFavorites]];

	NSString *agencyShortTitle;

	// determine agencyShortTitle
	if (direction != nil) agencyShortTitle = [NSString stringWithString:direction.route.agency.shortTitle];
	else {
		Agency *agency = [[destination.routes objectAtIndex:0] agency];
		agencyShortTitle = [NSString stringWithString:agency.shortTitle];
	}

	// go though the favorite stops and look one that matches
	for (NSDictionary *stopItem in favoriteStops) {

		NSString *stopItemTag = [stopItem valueForKey:@"tag"];
		NSString *stopItemAgencyShortTitle = [stopItem valueForKey:@"agencyShortTitle"];

		// if the current stop matches the stop tag and agency, look for the direction
		if ([stopItemTag isEqual:stop.tag]&&[stopItemAgencyShortTitle isEqual:agencyShortTitle]) {

			NSArray *directionItems = [stopItem objectForKey:@"lines"];

			// go through the favorited directions and look for the current direction information. if it's there, this stop/direction combo is favorited
			for (NSDictionary *directionItem in directionItems) {

				if (direction != nil) {
					// only if the route tag, direction name and directoin title match
					if ([[directionItem valueForKey:@"title"] isEqual:direction.title]&&
					    [[directionItem valueForKey:@"name"] isEqual:direction.name]&&
					    [[directionItem valueForKey:@"routeTag"] isEqual:direction.route.tag]) {

						return(YES);
					}
				} else
				// only if the route tag, direction name and directoin title match
				if ([[directionItem valueForKey:@"destinationStopTag"] isEqual:destination.destinationStop.tag]) {
					return(YES);
				}
			}
		}
	}
	return(NO);

}

+ (BOOL) addStopToFavorites:(Stop *)stop forLine:(id)line {
	Direction *direction = nil;
	Destination *destination = nil;

	if ([line isMemberOfClass:[Direction class]]) direction = (Direction *)line;
	else destination = (Destination *)line;
	// setup favorites file information
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *favoritesPath = [documentsDirectory stringByAppendingPathComponent:@"favorites.plist"];

	// create favorites dictionary
	NSMutableArray *favoriteStops = [[NSMutableArray alloc] initWithArray:[self getFavorites]];

	NSString *agencyShortTitle;

	// determine agencyShortTitle
	if (direction != nil) agencyShortTitle = [NSString stringWithString:direction.route.agency.shortTitle];
	else {
		Agency *agency = [[destination.routes objectAtIndex:0] agency];
		agencyShortTitle = [NSString stringWithString:agency.shortTitle];
	}
	NSMutableDictionary *stopItem = nil;             // the stop dictionary that we'll add the current direction to if the stop is already a favorite
	int stopItemIndex;

	// iterate through the favorites stops see if the current stop already there
	for (NSDictionary *item in favoriteStops) {

		NSString *favStopTag = [item valueForKey:@"tag"];
		NSString *favStopAgencyShortTitle = [item valueForKey:@"agencyShortTitle"];

		if ([favStopTag isEqual:stop.tag]&&[favStopAgencyShortTitle isEqual:agencyShortTitle]) {
			// if it exists, assign the stop dictionary to the stopItem variable
			stopItem = [NSMutableDictionary dictionaryWithDictionary:item];

			// be sure to place the stop back in the same position
			stopItemIndex = [favoriteStops indexOfObject:item];

			// remove the found stop so we can re-add it later, once we add the current direction to it
			[favoriteStops removeObject:item];
			break;
		}
	}

	// if a stop already exists for a given agency, add the direction to it
	if (stopItem != nil) {

		// find the existing array of directions favorited at this stop
		NSMutableArray *linesItem = [NSMutableArray arrayWithArray:[stopItem objectForKey:@"lines"]];

		// dictionary containing the direction/destination data to save
		NSDictionary *lineToSave;

		// determine direction/destination to save
		if (direction != nil) {

			// find the dirTags that match the direction name, title, and route tag
			// this info is used in showing the appropriate predictions on the favorites screen
			NSString *dirName = direction.name;
			NSString *dirTitle = direction.title;
			NSString *routeTag = direction.route.tag;

			NSArray *matchingDirTags = [DataHelper directionTagsInRoute:direction.route thatMatchDirectionName:dirName directionTitle:dirTitle];

			// NEXT BUS DIRECTION
			lineToSave = [NSDictionary dictionaryWithObjects:@[dirTitle, dirName, routeTag, direction.route.sortOrder, matchingDirTags]
				      forKeys:@[@"title", @"name", @"routeTag", @"routeSortOrder", @"matchingDirTags"]];
		} else
			// BART DESTINATION
			lineToSave = [NSDictionary dictionaryWithObjects:@[destination.destinationStop.tag, destination.destinationStop.title]
				      forKeys:@[@"destinationStopTag", @"destinationStopTitle"]];
		// add the current direction to the array
		[linesItem addObject:lineToSave];

		// replace the directions for the stopItem (which now includes the new direction)
		[stopItem setObject:linesItem forKey:@"lines"];

		// add the stopItem (we removed the current stop earlier so we could do this now)
		// add it to the corrent index (saved above)
		[favoriteStops insertObject:[self sortLinesInStopItem:stopItem] atIndex:stopItemIndex];

		// write the favorites dictionary to the favorites file
		[favoriteStops writeToFile:favoritesPath atomically:YES];

	} else {
		// otherwise, add the stop tag and the direction tag (to the agency node)


		// create a stopItem dictionary and add the direction tag, stop tag, and stop title
		NSMutableDictionary *stopItem = [[NSMutableDictionary alloc] init];
		[stopItem setValue:stop.tag forKey:@"tag"];
		[stopItem setValue:stop.title forKey:@"title"];
		[stopItem setValue:agencyShortTitle forKey:@"agencyShortTitle"];

		// add stopObjectID to stopItem

		NSURL *stopURI = [[stop objectID] URIRepresentation];
		NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:stopURI];
		[stopItem setObject:uriData forKey:@"stopURIData"];

		// dictionary containing the direction/destination data to save
		NSDictionary *lineToSave;

		// determine direction/destination to save
		if (direction != nil) {

			// find the dirTags that match the direction name, title, and route tag
			// this info is used in showing the appropriate predictions on the favorites screen
			NSString *dirName = direction.name;
			NSString *dirTitle = direction.title;
			NSString *routeTag = direction.route.tag;

			NSArray *matchingDirTags = [DataHelper directionTagsInRoute:direction.route thatMatchDirectionName:dirName directionTitle:dirTitle];

			// NEXT BUS DIRECTION
			lineToSave = [NSDictionary dictionaryWithObjects:@[dirTitle, dirName, routeTag, direction.route.sortOrder, matchingDirTags]
				      forKeys:@[@"title", @"name", @"routeTag", @"routeSortOrder", @"matchingDirTags"]];
		} else
			lineToSave = [NSDictionary dictionaryWithObjects:@[destination.destinationStop.tag, destination.destinationStop.title]
				      forKeys:@[@"destinationStopTag", @"destinationStopTitle"]];
		// add this direction dictionary to the directions array in stopItem
		[stopItem setObject:@[lineToSave] forKey:@"lines"];

		// add the stopItem (we removed the current stop earlier so we could do this now)
		[favoriteStops addObject:[self sortLinesInStopItem:stopItem]];

		// write the favorites array to the favorites file
		[favoriteStops writeToFile:favoritesPath atomically:YES];

	}


	return(YES);

}

+ (NSDictionary *) sortLinesInStopItem:(NSDictionary *)stopItem {

	NSArray *lineItems = [stopItem objectForKey:@"lines"];

	NSSortDescriptor *nextBusSorter = [[NSSortDescriptor alloc] initWithKey:@"routeSortOrder" ascending:YES];
	NSSortDescriptor *bartSorter = [[NSSortDescriptor alloc] initWithKey:@"destinationStopTitle" ascending:YES];
	NSSortDescriptor *directionTitleSorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	NSArray *sortedLineItems = [lineItems sortedArrayUsingDescriptors:@[nextBusSorter, directionTitleSorter, bartSorter]];


	[stopItem setValue:sortedLineItems forKey:@"lines"];

	return(stopItem);

}

+ (BOOL) removeStopFromFavorites:(Stop *)stop forLine:(id)line; {

	Direction *direction = nil;
	Destination *destination = nil;

	if ([line isMemberOfClass:[Direction class]]) direction = (Direction *)line;
	else destination = (Destination *)line;
	// setup favorites file information
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *favoritesPath = [documentsDirectory stringByAppendingPathComponent:@"favorites.plist"];

	// create favorites dictionary
	NSMutableArray *favoriteStops = [[NSMutableArray alloc] initWithArray:[self getFavorites]];

	NSString *agencyShortTitle;

	// determine agencyShortTitle
	if (direction != nil) agencyShortTitle = [NSString stringWithString:direction.route.agency.shortTitle];
	else {
		Agency *agency = [[destination.routes objectAtIndex:0] agency];
		agencyShortTitle = [NSString stringWithString:agency.shortTitle];
	}
	int stopItemIndex;

	// iterate through the items in the agency to find the stop to remove
	for (NSDictionary *item in favoriteStops) {

		NSString *stopItemTag = [item valueForKey:@"tag"];
		NSString *stopItemAgencyShortTitle = [item valueForKey:@"agencyShortTitle"];

		// if the current stop matches the stop tag and agency, look for the direction
		if ([stopItemTag isEqual:stop.tag]&&[stopItemAgencyShortTitle isEqual:agencyShortTitle]) {

			// when you find the stop, remove the current direction from it
			NSMutableDictionary *stopItem = [NSMutableDictionary dictionaryWithDictionary:item];

			// save the index of the stop, so you can readd to the same place
			stopItemIndex = [favoriteStops indexOfObject:item];

			// remove the found stop so we can re-add it later, once we remove the current direction from it
			[favoriteStops removeObject:item];

			// find the existing array of directions favorited at this stop
			NSMutableArray *directionItems = [NSMutableArray arrayWithArray:[stopItem objectForKey:@"lines"]];

			// remove the current direction from the directionItems array...
			for (NSDictionary *directionItem in directionItems) {

				if (direction != nil) {
					// only if the route tag, direction name and direction title match
					if ([[directionItem valueForKey:@"title"] isEqual:direction.title]&&
					    [[directionItem valueForKey:@"name"] isEqual:direction.name]&&
					    [[directionItem valueForKey:@"routeTag"] isEqual:direction.route.tag]) {

						[directionItems removeObject:directionItem];
						break;
					}
				} else
				// only if the route tag, direction name and direction title match
				if ([[directionItem valueForKey:@"destinationStopTag"] isEqual:destination.destinationStop.tag]) {

					[directionItems removeObject:directionItem];
					break;
				}
			}

			// if there are still more directions in the stopItem, return the stopItem to the agencyItem
			if ([directionItems count] != 0) {
				[stopItem setObject:directionItems forKey:@"lines"];

				// add the stopItem (we removed the current stop earlier so we could do this now)
				// add it to the corrent index (saved above)
				[favoriteStops insertObject:[self sortLinesInStopItem:stopItem] atIndex:stopItemIndex];

			}
			// if there are no more directions, don't add the stop back to the agencyItem

			// write the favorites dictionary to the favorites file
			[favoriteStops writeToFile:favoritesPath atomically:YES];

			break;  // don't repeat through the agency loop anymore
		}
	}
	return(YES);
}

// creates a new favorites plist file in the documents folder if one doesn't already exists and returns the favorites array based on that file
+ (NSArray *) getFavorites {

	// Look in Documents for an existing favorites file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *favoritesPath = [documentsDirectory stringByAppendingPathComponent:@"favorites.plist"];

	// If it's not there, create an empty one

	NSFileManager *fileManger = [NSFileManager defaultManager];

	if (![fileManger fileExistsAtPath:favoritesPath]) {

		NSArray *emptyFavorites = [[NSArray alloc] init];

		// create new plist file in the documents directory
		[emptyFavorites writeToFile:favoritesPath atomically:YES];


	} else {
	}
	// object that recieves this array needs to retain it
	return([NSArray arrayWithContentsOfFile:favoritesPath]);

}

@end
