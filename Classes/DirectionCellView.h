//
//  DirectionCellView.h
//  transporter
//
//  Created by Ljuba Miljkovic on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineCellView.h"
#import "Direction.h"


@interface DirectionCellView : LineCellView {

	Direction *direction;
	UILabel *directionTitleLabel;
}

@property (nonatomic, retain) Direction *direction;
@property (nonatomic, retain) UILabel *directionTitleLabel;
- (void)setFavoriteStatus;
- (void)toggleFavorite;

@end
