//
// DirectionAnnotationView.m
// kronos
//
// Created by Ljuba Miljkovic on 3/30/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DirectionAnnotationView.h"

@implementation DirectionAnnotationView

@synthesize pinView, calloutView, title, subtitle, mapFrame, calloutButton, direction;

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
	}
	return(self);
}

// given an x,y point on the map, adjust the frame of the annotation so that the base of the pin sticks into the map there.
- (void) setPoint:(CGPoint)point {

	// AC TRANSIT AND MUNI PINS FACE DIFFERENT DIRECTIONS AND HAVE DIFFERENT POINTS

	int xLocalOffset;
	int yLocalOffset;

	NSString *agencyShortTitle = self.direction.route.agency.shortTitle;

	if ([agencyShortTitle isEqualToString:@"actransit"]) {
		xLocalOffset = -5;
		yLocalOffset = 1;
	} else {
		xLocalOffset = 3;
		yLocalOffset = 1;
	}
	// set the initial position of the marker
	self.center = CGPointMake(point.x + xLocalOffset, point.y + kVerticalPinOffset + yLocalOffset);

	// FIGURE OUT BY HOW MUCH (DELTAX) THE MARKER NEEDS TO BE SHIFTED BY.
	// THEN SHIFT THE WHOLE MARKER BY THAT AMOUNT
	// THEN SHIFT JUST THE PIN IMAGE BACK BY THAT SAME AMOUNT
	// THE POINT IS TO HAVE A MARKER VIEW THAT ISN'T CLIPPED AT ALL.

	// pin x-position
	int pinX = self.center.x;
	int calloutViewWidth = self.calloutView.frame.size.width;

	int deltaX = 0;          // the amount by which the calloutView is shifted left or right

	// if the callout is too far to the left
	if ( (pinX - calloutViewWidth / 2) < kMapInset ) {

		int oldX = self.calloutView.center.x;
		int newX = oldX - (pinX - kMapInset - calloutViewWidth / 2);

		deltaX = newX - oldX;

	}
	// if the callout is too far to the right
	else if ( (pinX + calloutViewWidth / 2) > (self.mapFrame.size.width - kMapInset) ) deltaX = (self.mapFrame.size.width - kMapInset) - (pinX + calloutViewWidth / 2);
	// move the whole frame by the deltaX amount, then move the pin back by the same amount
	CGRect oldFrame = self.frame;
	CGRect newFrame = CGRectMake(oldFrame.origin.x + deltaX, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);

	self.frame = newFrame;

	// adjust the position of the pin to hit the right spot, now that the
	self.pinView.center = CGPointMake(self.pinView.center.x - deltaX, self.pinView.center.y);

}

// set annotation based on direction
- (void) setDirection:(Direction *)_direction {

	direction = _direction;
	self.title.text = self.direction.name;
	self.subtitle.text = self.direction.title;

	NSString *agencyShortTitle = self.direction.route.agency.shortTitle;

	if ([agencyShortTitle isEqualToString:@"actransit"]) self.pinView.image = [UIImage imageNamed:@"direction-pin-actransit.png"];

	else self.pinView.image = [UIImage imageNamed:@"direction-pin-sfmuni.png"];

}

- (IBAction) buttonTapped:(id)sender {

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"directionTapped" object:self.direction];

}


@end
