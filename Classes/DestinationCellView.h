//
// DestinationCellView.h
// transporter
//
// Created by Ljuba Miljkovic on 4/25/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BartColorsView.h"
#import "Destination.h"
#import "LineCellView.h"
#import <UIKit/UIKit.h>

@interface DestinationCellView : LineCellView {

	Destination *destination;
	BartColorsView *bartColorsView;

}

@property (nonatomic) Destination *destination;
@property (nonatomic) BartColorsView *bartColorsView;

- (void) setFavoriteStatus;
- (void) toggleFavorite;

@end
