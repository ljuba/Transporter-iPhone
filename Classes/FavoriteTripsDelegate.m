//
// FavoriteTripsDelegate.m
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FavoriteTripsDelegate.h"

@implementation FavoriteTripsDelegate

#pragma mark Table view methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return(0);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return(0);
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	cell.textLabel.text = @"";

	return(cell);
}

@end
