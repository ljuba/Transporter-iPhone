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

@interface DirectionCellView : LineCellView 

@property (nonatomic, strong) Direction *direction;
@property (nonatomic, strong) UILabel *directionTitleLabel;

- (void) setFavoriteStatus;
- (void) toggleFavorite;

@end
