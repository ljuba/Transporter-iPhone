//
// DirectionCellView.h
// transporter
//
// Created by Ljuba Miljkovic on 4/25/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Direction.h"
#import "LineCellView.h"
#import <UIKit/UIKit.h>

@interface DirectionCellView : LineCellView {

	Direction *direction;
	UILabel *directionTitleLabel;
}

@property (nonatomic) Direction *direction;
@property (nonatomic) UILabel *directionTitleLabel;
- (void) setFavoriteStatus;
- (void) toggleFavorite;

@end
