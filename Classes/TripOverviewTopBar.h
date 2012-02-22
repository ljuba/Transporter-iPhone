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

@property (nonatomic) UIButton *nextTripButton;
@property (nonatomic) UIButton *previousTripButton;
@property (nonatomic) UILabel *timespanLabel;
@property (nonatomic) UILabel *tripOptionLabel;

- (void) previousTripButtonTapped;
- (void) nextTripButtonTapped;

@end
