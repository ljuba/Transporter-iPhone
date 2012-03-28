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
#import "sfMuniDelegate.h"

#import "DirectionsVC.h"

@implementation sfMuniDelegate

@synthesize formattedContents;

// initializes the formatting of the sf muni lines in the table
- (id) initWithAgency:(Agency *)agency {

	if (self = [super init]) {

		// sets the contents variable to the routes in this agency

		[self setContentsForAgency:agency];

		// this array will contain arrays or routes. there will be kLinesPerRow number of routes per subarray
		self.formattedContents = [self formatContentsForAgency:agency];

	}

	return(self);
}

#pragma mark Table view methods

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return(kRowHeight);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return([self.formattedContents count]);
}

// Customize the number of rows in the table view.
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return([[self.formattedContents objectAtIndex:section] count]);
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return(kRowDividerHeight);

}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	RowDivider *header = [[RowDivider alloc] initWithFrame:CGRectMake(0, 0, 320, kRowDividerHeight)];

	switch (section) {
	case 0:
		header.title = @"Metro/Streetcar Lines";
		break;
	case 1:
		header.title = @"Cable Car Lines";
		break;
	case 2:
		header.title = @"Bus Lines";
		break;
	default:
		break;
	}
	return(header);
}

// user taps a route to see it's directions
- (void) tapRoute:(UIButton *)sender {

	NSLog(@"sfMuniDelegate: %@", @"Button Tapped"); /* DEBUG LOG */

	int tag = sender.tag;
    
	DirectionsVC *directionsTableViewController = [[DirectionsVC alloc] init];
    directionsTableViewController.route = [self.contents objectAtIndex:tag - 1];
    
    [self.parentViewController.navigationController pushViewController:directionsTableViewController animated:YES];
}

// Customize the appearance of table view cells. Doesn't reuse cells b/c of the overhead in creating/deleting buttons
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *SFMuniRoutesCellIdentifier = @"SFMuniRoutesCellIdentifier";

	RoutesCell *cell = (RoutesCell *)[tableView dequeueReusableCellWithIdentifier:SFMuniRoutesCellIdentifier];

	if (cell == nil) cell = [[RoutesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SFMuniRoutesCellIdentifier];
	// current row index
	int row = indexPath.row;
	int section = indexPath.section;

	NSArray *rowRoutes = [[self.formattedContents objectAtIndex:section] objectAtIndex:row];

	// button formatting
	int buttonWidth;
	int buttonLabelFontSize;
	UIImage *buttonBackgroundEnabled;
	UIImage *buttonBackgroundHighlighted;

	if ( (section == 1)||(section == 0) ) {
		buttonWidth = cell.frame.size.width / 3;
		buttonBackgroundEnabled = [UIImage imageNamed:@"route-wide-button-background-enabled.png"];
		buttonBackgroundHighlighted = [UIImage imageNamed:@"route-wide-button-background-highlighted.png"];
		buttonLabelFontSize = 20;
	} else {
		buttonWidth = cell.frame.size.width / kLinesPerRow;
		buttonBackgroundEnabled = [UIImage imageNamed:@"route-button-background-enabled.png"];
		buttonBackgroundHighlighted = [UIImage imageNamed:@"route-button-background-highlighted.png"];
		buttonLabelFontSize = 22;
	}
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
		else

			// create the number of needed buttons (-numberOfExtraButtons) and add them to the buttons array
			for (int i = 0; i < -numberOfExtraButtons; i++) {

				UIButton *rowButton = [UIButton buttonWithType:UIButtonTypeCustom];

				[rowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
				[rowButton setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:1.0] forState:UIControlStateNormal];
				[rowButton setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:0] forState:UIControlStateHighlighted];
				[rowButton setTitleShadowColor:[UIColor colorWithWhite:0.9 alpha:0] forState:UIControlStateSelected];

				rowButton.titleLabel.shadowOffset = CGSizeMake(-1, 1);
				rowButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
				rowButton.titleLabel.textAlignment = UITextAlignmentCenter;
				rowButton.opaque = YES;

				[rowButton addTarget:self action:@selector(tapRoute:) forControlEvents:UIControlEventTouchUpInside];
				[cell.buttons addObject:rowButton];

				[cell addSubview:rowButton];

			}
		// reformat buttons

		for (UIButton *button in cell.buttons) {

			int i = [cell.buttons indexOfObject:button];

			// in the case of sf muni, the middle button in rows with 3 buttons is 2 pixels wider.
			// by setting a separate variable called adjustedButtonWidth, I can make the adjustment for just that buttton
			int adjustedButtonWidth = buttonWidth;

			float x = buttonWidth * i;       // the x position of the buttons is a multiple of its width. firstNewButtonIndex + however many buttons come after that
			float y = 0;

			if (section == 1) {

				switch (i) {
				case 1:
					adjustedButtonWidth = buttonWidth + 2;
					break;
				case 2:
					x = x + 2;
					break;
				default:
					break;
				}
			}
			button.frame = CGRectMake(x, y, adjustedButtonWidth, buttonHeight);
			[button setBackgroundImage:buttonBackgroundEnabled forState:UIControlStateNormal];
			[button setBackgroundImage:buttonBackgroundHighlighted forState:UIControlStateHighlighted];
			button.titleLabel.font = [UIFont boldSystemFontOfSize:buttonLabelFontSize];

		}
	}

	// populate the button contents
	for (Route *route in rowRoutes) {

		int buttonIndex = [rowRoutes indexOfObject:route];

		UIButton *rowButton = [cell.buttons objectAtIndex:buttonIndex];
		rowButton.tag = [route.sortOrder intValue];              // unique tag for each button

		// NSLog(@"%@", route.sortOrder); /* DEBUG LOG */

		if (section == 1) {
			// cable car sections need to show route titles
			NSString *buttonTitle;

			if ([route.title isEqualToString:@"PowllMason Cable"]) buttonTitle = @"Powell Mason";
			else if ([route.title isEqualToString:@"PowellHyde Cable"]) buttonTitle = @"Powell Hyde";
			else if ([route.title isEqualToString:@"Calif. Cable Car"]) buttonTitle = @"California";
			else buttonTitle = [route.title stringByReplacingOccurrencesOfString:@" Cable Car" withString:@""];
			[rowButton setTitle:[buttonTitle stringByReplacingOccurrencesOfString:@"/" withString:@"\n"] forState:UIControlStateNormal];
		} else [rowButton setTitle:route.tag forState:UIControlStateNormal];
	}
	cell.opaque = YES;

	[cell setNeedsDisplay];

	return(cell);
}

#pragma mark -
#pragma mark Memory


@end
