//
// TransitDelegate.m
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TransitDelegate.h"

@implementation TransitDelegate

@synthesize contents, selectedItem, parentViewController;

// setup datasource by retrieving all the routes for the agency and ordering them
- (void) setContentsForAgency:(Agency *)agency {

	self.contents = [NSMutableArray arrayWithArray:[agency.routes allObjects]];

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	[self.contents sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

}

#pragma mark Table view methods
#pragma mark Overridden by subclasses

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return(1);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return(0);
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return(nil);
}

- (NSArray *) formatContentsForAgency:(Agency *)agency {

	NSMutableArray *structuredContents = [NSMutableArray array];

	if ([agency.shortTitle isEqual:@"actransit"]) {

		NSMutableArray *rowContents = [[NSMutableArray alloc] init];

		// for all routes
		for (Route *route in contents) {

			[rowContents addObject:route];

			// if this is the last route in the metroContents array, add the current rowConents to the structuredContents array
			if ([contents indexOfObject:route] == [contents count] - 1) [structuredContents addObject:rowContents];

			// if the row is full, add it to the structuredContents array and create a new rowContents array
			else if ([rowContents count] == kLinesPerRow) {

				[structuredContents addObject:rowContents];
				rowContents = [NSMutableArray array];

			}
		}
	}
	// format muni agency content. group by vehicle type
	else if ([agency.shortTitle isEqual:@"sf-muni"]) {

		// METRO+STREETCAR SECTION
		NSPredicate *metroPredicate = [NSPredicate predicateWithFormat:@"vehicle == %@ || vehicle == %@", @"metro", @"streetcar"];
		NSArray *metroContents = [contents filteredArrayUsingPredicate:metroPredicate];

		NSMutableArray *rowContents = [[NSMutableArray alloc] init];

		// create first section in structuredContents array for metro lines
		[structuredContents insertObject:[NSMutableArray array] atIndex:0];

		// for all metro and streetcar routes
		for (Route *route in metroContents) {

			[rowContents addObject:route];

			// if this is the last route in the metroContents array, add the current rowConents to the structuredContents array
			if ([metroContents indexOfObject:route] == [metroContents count] - 1) [[structuredContents objectAtIndex:0] addObject:rowContents];

			// if the row is full, add it to the structuredContents array and create a new rowContents array
			else if ([rowContents count] == 3) {

				[[structuredContents objectAtIndex:0] addObject:rowContents];
				rowContents = [NSMutableArray array];

			}
		}
		// CABLE CAR SECTION
		NSPredicate *cablecarPredicate = [NSPredicate predicateWithFormat:@"vehicle == %@", @"cablecar"];
		NSArray *cableCarContents = [contents filteredArrayUsingPredicate:cablecarPredicate];

		rowContents = [[NSMutableArray alloc] init];

		// create first section in structuredContents array for metro lines
		[structuredContents insertObject:[NSMutableArray array] atIndex:1];

		// for all metro and streetcar routes
		for (Route *route in cableCarContents) {

			[rowContents addObject:route];

			// if this is the last route in the metroContents array, add the current rowConents to the structuredContents array
			if ([cableCarContents indexOfObject:route] == [cableCarContents count] - 1) [[structuredContents objectAtIndex:1] addObject:rowContents];

			// if the row is full, add it to the structuredContents array and create a new rowContents array
			else if ([rowContents count] == 3) {

				[[structuredContents objectAtIndex:1] addObject:rowContents];
				rowContents = [NSMutableArray array];

			}
		}
		// BUS SECTION
		NSPredicate *busPredicate = [NSPredicate predicateWithFormat:@"vehicle == %@", @"bus"];
		NSArray *busContents = [contents filteredArrayUsingPredicate:busPredicate];

		rowContents = [[NSMutableArray alloc] init];

		// create first section in structuredContents array for metro lines
		[structuredContents insertObject:[NSMutableArray array] atIndex:2];

		// for all metro and streetcar routes
		for (Route *route in busContents) {

			[rowContents addObject:route];

			// if this is the last route in the metroContents array, add the current rowConents to the structuredContents array
			if ([busContents indexOfObject:route] == [busContents count] - 1) [[structuredContents objectAtIndex:2] addObject:rowContents];

			// if the row is full, add it to the structuredContents array and create a new rowContents array
			else if ([rowContents count] == kLinesPerRow) {

				[[structuredContents objectAtIndex:2] addObject:rowContents];
				rowContents = [NSMutableArray array];

			}
		}
	} else if ([agency.shortTitle isEqual:@"bart"]) {
		// format bart content (don't think there's anything to do)
	}
	// NSLog(@"%@",[[structuredContents objectAtIndex:14] class]);

	return(structuredContents);

}


@end
