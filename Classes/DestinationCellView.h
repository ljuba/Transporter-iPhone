//
//  DestinationCellView.h
//  transporter
//
//  Created by Ljuba Miljkovic on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineCellView.h"
#import "Destination.h"
#import "BartColorsView.h"

@interface DestinationCellView : LineCellView {

	Destination *destination;
	BartColorsView *bartColorsView;
	
}

@property (nonatomic, retain) Destination *destination;
@property (nonatomic, retain) BartColorsView *bartColorsView;

- (void)setFavoriteStatus;
- (void)toggleFavorite;

@end
