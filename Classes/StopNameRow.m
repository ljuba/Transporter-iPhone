//
// StopNameRow.m
// kronos
//
// Created by Ljuba Miljkovic on 4/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopNameRow.h"

@implementation StopNameRow

@synthesize stopName, backgroundImage;

- (id) initWithStopName:(NSString *)name agencyShortTitle:(NSString *)agencyShortTitle {

	if (self = [super init]) {

		[self setBackgroundWithStopName:name agencyShortTitle:agencyShortTitle];

		CGRect frame = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);

		self.frame = frame;

		CGRect labelFrame = CGRectMake(19, 7, 275, 25);

		UILabel *stopNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
		stopNameLabel.text = stopName;
		stopNameLabel.font = [UIFont boldSystemFontOfSize:17];
		stopNameLabel.textColor = [UIColor whiteColor];
		stopNameLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		stopNameLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.25];
		stopNameLabel.shadowOffset = CGSizeMake(-1, -1);

		[self addSubview:stopNameLabel];

	}
	return(self);
}

- (void) setBackgroundWithStopName:(NSString *)name agencyShortTitle:(NSString *)agencyShortTitle {

	self.stopName = name;
	self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];

	if ([agencyShortTitle isEqual:@"bart"])	backgroundImage = [UIImage imageNamed:@"fav-bart-stop-background.png"];
	else if ([agencyShortTitle isEqual:@"sf-muni"])	backgroundImage = [UIImage imageNamed:@"fav-muni-stop-background.png"];
	else if ([agencyShortTitle isEqual:@"actransit"]) backgroundImage = [UIImage imageNamed:@"fav-actransit-stop-background.png"];
}

- (void) drawRect:(CGRect)rect {

	CGPoint backgroundPoint = CGPointZero;

	[backgroundImage drawAtPoint:backgroundPoint];

}


@end
