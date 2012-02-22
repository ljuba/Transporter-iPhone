//
// TripOverviewBottomBar.h
// kronos
//
// Created by Ljuba Miljkovic on 4/20/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Trip.h"
#import <UIKit/UIKit.h>

@interface TripOverviewBottomBar : UIView {

	Trip *trip;

	UILabel *durationLabel;
	UILabel *costLabel;

}

@property (nonatomic) Trip *trip;
@property (nonatomic) UILabel *durationLabel;
@property (nonatomic) UILabel *costLabel;

@end
