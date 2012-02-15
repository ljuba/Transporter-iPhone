//
//  DirectionCellView.m
//  transporter
//
//  Created by Ljuba Miljkovic on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DirectionCellView.h"
#import "FavoritesManager.h"

@implementation DirectionCellView

@synthesize direction, directionTitleLabel;

- (id)init {

	//calls the LineCellView init method
	if (self = [super init]) {
		
		direction = nil;
				
		self.font = [UIFont boldSystemFontOfSize:25];
		
		directionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 32, 197, 25)];
		directionTitleLabel.font = [UIFont boldSystemFontOfSize:14];
		directionTitleLabel.textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
		directionTitleLabel.adjustsFontSizeToFitWidth = YES;
		directionTitleLabel.text = @"";
		directionTitleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		[self addSubview:directionTitleLabel];
		
	}
	
	return self;
}

- (void)toggleFavorite {
	
	//toggle button status
	if (isFavorite) {
		
		//toggle button if removal from plist is successful
		if ([FavoritesManager removeStopFromFavorites:stop forLine:direction]) {
			isFavorite = NO;
			[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateNormal];
			[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateHighlighted];
		}
	}
	else {
		
		//toggle button if additing from plist is successful
		if ([FavoritesManager addStopToFavorites:stop forLine:direction]) {
			isFavorite = YES;
			[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateNormal];
			[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateHighlighted];
		}
	}
}

//sets the color of the star icon depending on whether the stop/direction combo is a favorite
- (void)setFavoriteStatus {
		
	if ([FavoritesManager isFavoriteStop:stop forLine:direction]) {
		[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateNormal];
		[favoriteButton setImage:[UIImage imageNamed:@"star-selected.png"] forState:UIControlStateHighlighted];
		self.isFavorite = YES;
	}
	else {
		[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateNormal];
		[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateHighlighted];
	}

}

- (void)setCellStatus:(int)status withArrivals:(NSArray *)arrivals {

	[super setCellStatus:status withArrivals:arrivals];
	
	//set the direction title to gray if there are no arrivals
	if (cellStatus == kCellStatusDefault) {
		
		directionTitleLabel.textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
		
		int numberOfArrivals = [arrivals count];
		switch (numberOfArrivals) {
			case 0:
				directionTitleLabel.textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:0.6];
				break;
			case 1:
				[prediction1Label setEpochTime:[[arrivals objectAtIndex:0] valueForKey:@"epochTime"]];
				break;
			case 2:
				[prediction1Label setEpochTime:[[arrivals objectAtIndex:0] valueForKey:@"epochTime"]];
				[prediction2Label setEpochTime:[[arrivals objectAtIndex:1] valueForKey:@"epochTime"]];
				break;
			default:
				[prediction1Label setEpochTime:[[arrivals objectAtIndex:0] valueForKey:@"epochTime"]];
				[prediction2Label setEpochTime:[[arrivals objectAtIndex:1] valueForKey:@"epochTime"]];
				[prediction3Label setEpochTime:[[arrivals objectAtIndex:2] valueForKey:@"epochTime"]];
				break;
		}		
	}
}

- (void)dealloc {
    [directionTitleLabel release];
	[direction release];
	[super dealloc];
}


@end
