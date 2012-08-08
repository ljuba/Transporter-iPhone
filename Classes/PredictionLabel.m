//
// PredictionLabel.m
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "LineCellView.h"
#import "PredictionLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation PredictionLabel

@synthesize timer, arrivalTime, imminentArrivalMarker, isMarkerAnimating;

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {

		// SETUP IMMINENT MARKER
		self.imminentArrivalMarker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-marker.png"]];
		self.imminentArrivalMarker.contentMode = UIViewContentModeScaleAspectFit;
		self.imminentArrivalMarker.hidden = YES;
		self.isMarkerAnimating = NO;

		int markerCenterX = floor(self.bounds.size.width / 2);
		int markerCenterY = floor(self.bounds.size.height / 2);
		int markerHeight = floor(self.bounds.size.height * 0.6);

		self.imminentArrivalMarker.bounds = CGRectMake(0, 0, self.imminentArrivalMarker.frame.size.width, markerHeight);
		self.imminentArrivalMarker.center = CGPointMake(markerCenterX, markerCenterY);

		[self addSubview:self.imminentArrivalMarker];

	}
	return(self);
}

- (void) setIsFirstArrival:(BOOL)first {

	isFirstArrival = first;

	if (isFirstArrival) {

		int markerCenterX = floor(self.bounds.size.width / 2);
		int markerCenterY = floor(self.bounds.size.height / 2) + 5;
		self.imminentArrivalMarker.center = CGPointMake(markerCenterX, markerCenterY);
	}
}

- (BOOL) isFirstArrival {

	return(isFirstArrival);
}

// sets the actual time the bus will arrive
- (void) setEpochTime:(NSString *)time {

	// received epochTime is in miliseconds
	self.arrivalTime = [NSDate dateWithTimeIntervalSince1970:([time doubleValue] / 1000)];

	// determine number of minutes-from-now label
	NSTimeInterval timeFromNow = [self.arrivalTime timeIntervalSinceNow];

	// if bus is less then 1 minute away
	if (timeFromNow < 60) {

		if (!isMarkerAnimating) {
			self.text = nil;
			self.imminentArrivalMarker.hidden = NO;
			isMarkerAnimating = YES;
			[self startAnimation];
		}

		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalYES" object:self.superview]];
		}
	} else {
		self.imminentArrivalMarker.hidden = YES;
		isMarkerAnimating = NO;
		[self.imminentArrivalMarker.layer removeAllAnimations];

		int minutes = (int)floor(timeFromNow / 60);
		self.text = [NSString stringWithFormat:@"%d", minutes];

		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalNO" object:self.superview]];
		}
	}
}

// called whenever you want to clear the prediction label
- (void) clear {

	self.text = nil;
	self.imminentArrivalMarker.hidden = YES;
	isMarkerAnimating = NO;

}

- (void) setBartTime:(NSString *)bartTime {

	self.arrivalTime = nil;          // dummy object so it can be released in dealloc

	if ([bartTime isEqual:@"Leaving"]) {
		self.text = nil;

		if (!isMarkerAnimating) {
			self.imminentArrivalMarker.hidden = NO;
			isMarkerAnimating = YES;
			[self startAnimation];
		}

		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalYES" object:self.superview]];
		}
	} else {
		self.imminentArrivalMarker.hidden = YES;
		isMarkerAnimating = NO;
		[self.imminentArrivalMarker.layer removeAllAnimations];
		self.text = bartTime;

		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalNO" object:self.superview]];
		}
	}
}

- (void) startAnimation {

	CABasicAnimation *theAnimation;

	theAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	theAnimation.duration = 1.0;
	theAnimation.repeatCount = 200;
	theAnimation.autoreverses = YES;
	theAnimation.fromValue = @0.3f;
	theAnimation.toValue = @1.0f;
	theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[self.imminentArrivalMarker.layer addAnimation:theAnimation forKey:@"animateOpacity"];
}


@end
