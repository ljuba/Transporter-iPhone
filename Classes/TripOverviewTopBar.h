//
// TripOverviewTopBar.h
// kronos
//
// Created by Ljuba Miljkovic on 4/20/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripOverviewTopBar : UIView {

	UIButton *nextTripButton;
	UIButton *previousTripButton;

	UILabel *timespanLabel;
	UILabel *tripOptionLabel;

}

@property (nonatomic, retain) UIButton *nextTripButton;
@property (nonatomic, retain) UIButton *previousTripButton;
@property (nonatomic, retain) UILabel *timespanLabel;
@property (nonatomic, retain) UILabel *tripOptionLabel;

- (void) previousTripButtonTapped;
- (void) nextTripButtonTapped;

@end
