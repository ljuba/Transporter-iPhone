//
// DestinationCellView.m
// transporter
//
// Created by Ljuba Miljkovic on 4/25/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BartColorsView.h"
#import "DestinationCellView.h"
#import "FavoritesManager.h"

@implementation DestinationCellView

@synthesize destination, bartColorsView;

- (id) init {
	if (self = [super init]) self.font = [UIFont boldSystemFontOfSize:21];
	return(self);
}

// sets the color of the star icon depending on whether the stop/direction combo is a favorite
- (void) setFavoriteStatus {

	if ([FavoritesManager isFavoriteStop:stop forLine:destination]) {
		[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateNormal];
		[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateHighlighted];
		self.isFavorite = YES;
	} else {
		[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateNormal];
		[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateHighlighted];
	}
}

- (void) toggleFavorite {

	// toggle button status
	if (isFavorite) {

		// toggle button if removal from plist is successful
		if ([FavoritesManager removeStopFromFavorites:stop forLine:destination]) {
			isFavorite = NO;
			[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateNormal];
			[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateHighlighted];
		}
	} else
	// toggle button if additing from plist is successful
	if ([FavoritesManager addStopToFavorites:stop forLine:destination]) {
		isFavorite = YES;
		[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateNormal];
		[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateHighlighted];
	}
}

- (void) setDestination:(Destination *)dest {

	destination = dest;

	[bartColorsView removeFromSuperview];           // remove bartColorsView from dequeued destinationcellview

	bartColorsView = [[BartColorsView alloc] initWithColors:destination.colors atPoint:CGPointMake(37, 36)];
	[self addSubview:bartColorsView];
	[self setNeedsDisplay];

}

- (void) setCellStatus:(int)status withArrivals:(NSArray *)arrivals {

	[super setCellStatus:status withArrivals:arrivals];

	// set the direction title to gray if there are no arrivals
	if (cellStatus == kCellStatusDefault) {

		int numberOfArrivals = [arrivals count];

		switch (numberOfArrivals) {
		case 0:
			break;
		case 1:
			[prediction1Label setBartTime:[[arrivals objectAtIndex:0] valueForKey:@"minutes"]];
			break;
		case 2:
			[prediction1Label setBartTime:[[arrivals objectAtIndex:0] valueForKey:@"minutes"]];
			[prediction2Label setBartTime:[[arrivals objectAtIndex:1] valueForKey:@"minutes"]];
			break;
		default:
			[prediction1Label setBartTime:[[arrivals objectAtIndex:0] valueForKey:@"minutes"]];
			[prediction2Label setBartTime:[[arrivals objectAtIndex:1] valueForKey:@"minutes"]];
			[prediction3Label setBartTime:[[arrivals objectAtIndex:2] valueForKey:@"minutes"]];
			break;
		}
	}
}


@end
