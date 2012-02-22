//
// TripOverviewBottomBar.m
// kronos
//
// Created by Ljuba Miljkovic on 4/20/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TransitLeg.h"
#import "TripOverviewBottomBar.h"
#import "WalkingLeg.h"

#define kTripOverviewBottomBarMargin 3

@implementation TripOverviewBottomBar

@synthesize trip, durationLabel, costLabel;

- (id) init {

	if ( (self = [super init]) ) {

		self.frame = CGRectMake(0, 347, 320, 20);
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];

		// SETUP BACKGROUND IMAGE
		UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-bar-background-tile.png"]];
		backgroundImageView.frame = self.bounds;
		backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		backgroundImageView.alpha = 0.95;
		[self addSubview:backgroundImageView];

		// SETUP COST LABEL
		costLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, 100, self.frame.size.height)];
		costLabel.center = CGPointMake(320 / 2, self.frame.size.height / 2);
		costLabel.font = [UIFont boldSystemFontOfSize:13];
		costLabel.textAlignment = UITextAlignmentCenter;
		costLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		costLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		[self addSubview:costLabel];

		// SETUP TRIP DURATION LABEL
		durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, 100, self.frame.size.height)];
		durationLabel.font = [UIFont boldSystemFontOfSize:13];
		durationLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		durationLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		[self addSubview:durationLabel];

		// SETUP CLOCK ICON
		UIImageView *clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock-icon.png"]];
		clockImageView.bounds = CGRectMake(0, 0, 13, 13);
		clockImageView.center = CGPointMake(kTripOverviewBottomBarMargin + 10, 10);

		[self addSubview:clockImageView];
	}
	return(self);
}

- (void) setTrip:(Trip *)_trip {

	trip = _trip;

	// SETUP TRIP DURATION
	durationLabel.text = [trip durationLabelText];

	// SETUP COST
	costLabel.text = [trip costLabelText];

	// SETUP TRIP LEG ICONS

	// remove any previous iconViews
	for (UIView *view in self.subviews)
		if (view.tag == 77) {
			[view removeFromSuperview];
			break;
		}
	int iconSize = 15;
	int iconSpacing = 3;

	int numberOfLegs = [trip.legs count];
	int iconViewX = 320 - (numberOfLegs * iconSize + (numberOfLegs - 1) * iconSpacing + kTripOverviewBottomBarMargin);

	CGRect iconViewFrame = CGRectMake(iconViewX, iconSpacing, 320 - iconViewX, iconSize);

	UIView *iconView = [[UIView alloc] initWithFrame:iconViewFrame];
	iconView.tag = 77;

	// go through trip legs backwards and add the icons from the right in that order
	for (int i = 0; i <= numberOfLegs - 1; i++) {

		CGRect iconFrame = CGRectMake( (iconSize + iconSpacing) * i, 0, iconSize, iconSize );
		UIImageView *icon = [[UIImageView alloc] initWithFrame:iconFrame];

		id leg = [trip.legs objectAtIndex:i];

		if ([leg isMemberOfClass:[WalkingLeg class]]) icon.image = [UIImage imageNamed:@"walking-icon.png"];

		else {
			TransitLeg *transitLeg = (TransitLeg *)leg;

			NSString *agencyShortTitle = transitLeg.agency.shortTitle;

			if ([agencyShortTitle isEqualToString:@"bart"])	icon.image = [UIImage imageNamed:@"bart-icon.png"];
			else if ([agencyShortTitle isEqualToString:@"sf-muni"]) {

				Route *route = [[transitLeg.startStop.directions anyObject] route];

				if ([route.vehicle isEqualToString:@"bus"]) icon.image = [UIImage imageNamed:@"bus-icon.png"];
				else icon.image = [UIImage imageNamed:@"rail-icon.png"];
			} else icon.image = [UIImage imageNamed:@"bus-icon.png"];
		}
		[iconView addSubview:icon];
	}
	[self addSubview:iconView];


}


@end
