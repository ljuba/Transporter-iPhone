//
// acTransitDelegate.m
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "RoutesCell.h"
#import "RowDivider.h"
#import "acTransitDelegate.h"

@implementation acTransitDelegate

@synthesize formattedContents;

// initializes the formatting of the ac transit lines in the table
- (id) initWithAgency:(Agency *)agency {

	if (self = [super init]) {

		// sets the contents variable to the routes in this agency
		[self setContentsForAgency:agency];

		// this array will contain arrays or routes. there will be kLinesPerRow number of routes per subarray
		self.formattedContents = [self formatContentsForAgency:agency];

		// set the selectedItem to nil to start
		self.selectedItem = nil;

	}
	return(self);
}

// user taps a route to see it's directions
- (void) tapRoute:(UIButton *)sender {

	int tag = sender.tag;

	NSLog(@"acTransitDelegate: %@", @"Button Tapped"); /* DEBUG LOG */

	self.selectedItem = [self.contents objectAtIndex:tag];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"routeSelected" object:self];

}

#pragma mark Table view methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return(kRowHeight);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return(1);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return([self.formattedContents count]);
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	return(kRowDividerHeight);
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	RowDivider *header = [[RowDivider alloc] initWithFrame:CGRectMake(0, 0, 320, kRowDividerHeight)];

	header.title = @"Bus Lines";

	return(header);
}

// Customize the appearance of table view cells. Doesn't reuse cells b/c of the overhead in creating/deleting buttons
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *ACTransitRoutesCellIdentifier = @"ACTransitRoutesCellIdentifier";

	RoutesCell *cell = (RoutesCell *)[tableView dequeueReusableCellWithIdentifier:ACTransitRoutesCellIdentifier];

	if (cell == nil) cell = [[RoutesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ACTransitRoutesCellIdentifier];
	// current row index
	int row = indexPath.row;
	NSArray *rowRoutes = [self.formattedContents objectAtIndex:row];

	// button formatting
	int buttonWidth = cell.frame.size.width / kLinesPerRow;
	int buttonHeight = kRowHeight;

	// delete or add the line buttons you need to (if any) and relabel the ones you need
	if ([rowRoutes count] != [cell.buttons count]) {

		int numberOfExtraButtons = [cell.buttons count] - [rowRoutes count];

		// remove extra buttons
		if (numberOfExtraButtons > 0)

			// remove the number of buttons from the end of the buttons array you need to. remove the actual buttons from the cell too
			for (int i = 0; i < numberOfExtraButtons; i++) {

				UIButton *lastButton = [cell.buttons lastObject];
				[lastButton removeFromSuperview];
				[cell.buttons removeLastObject];

			}
		// add needed buttons (number of extra buttons < 0. this is the number of buttons we need
		else {

			// if there are no buttons in the row, the next button index is 0. if there are 2 buttons already in the row, the next button index is 2
			int firstNewButtonIndex = [cell.buttons count];  // index of the next button to add. if there are no button, index is 0, etc.

			// create the number of needed buttons (-numberOfExtraButtons) and add them to the buttons array
			for (int i = 0; i < -numberOfExtraButtons; i++) {

				float x = buttonWidth * (firstNewButtonIndex + i);        // the x position of the buttons is a multiple of its width. firstNewButtonIndex + however many buttons come after that
				float y = 0;

				UIButton *rowButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[rowButton setBackgroundImage:[UIImage imageNamed:@"route-button-background-enabled.png"] forState:UIControlStateNormal];
				[rowButton setBackgroundImage:[UIImage imageNamed:@"route-button-background-highlighted.png"] forState:UIControlStateHighlighted];
				rowButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
				[rowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

				[rowButton setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:1.0] forState:UIControlStateNormal];
				[rowButton setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:0] forState:UIControlStateHighlighted];
				[rowButton setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:0] forState:UIControlStateSelected];

				rowButton.titleLabel.shadowOffset = CGSizeMake(-1, 1);

				rowButton.opaque = YES;

				[rowButton addTarget:self action:@selector(tapRoute:) forControlEvents:UIControlEventTouchUpInside];
				rowButton.frame = CGRectMake(x, y, buttonWidth, buttonHeight);
				[cell.buttons addObject:rowButton];

				[cell addSubview:rowButton];

			}
		}
	}

	// populate the button contents
	for (Route *route in rowRoutes) {

		int buttonIndex = [rowRoutes indexOfObject:route];

		UIButton *rowButton = [cell.buttons objectAtIndex:buttonIndex];
		rowButton.tag = row * kLinesPerRow + buttonIndex;         // unique tag for each button

		[rowButton setTitle:route.tag forState:UIControlStateNormal];

	}
	cell.opaque = YES;
	[cell setNeedsDisplay];

	return(cell);
}

#pragma mark -
#pragma mark Memory


@end
