//
// PredictionLabel.h
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PredictionLabel : UILabel {

	NSDate *arrivalTime;
	NSTimer *timer;

	UIImageView *imminentArrivalMarker;

	BOOL isFirstArrival;
	BOOL isMarkerAnimating;
}

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSDate *arrivalTime;
@property (nonatomic, retain) UIImageView *imminentArrivalMarker;
@property BOOL isFirstArrival;
@property BOOL isMarkerAnimating;

- (void) setEpochTime:(NSString *)time;
- (void) setBartTime:(NSString *)bartTime;
- (void) clear;
- (void) startAnimation;

@end
