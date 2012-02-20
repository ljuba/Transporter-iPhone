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

@property (nonatomic, retain) Trip *trip;
@property (nonatomic, retain) UILabel *durationLabel;
@property (nonatomic, retain) UILabel *costLabel;

@end
