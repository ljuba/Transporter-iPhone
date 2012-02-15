//
//  TripOverviewTopBar.m
//  kronos
//
//  Created by Ljuba Miljkovic on 4/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripOverviewTopBar.h"


@implementation TripOverviewTopBar

@synthesize nextTripButton, previousTripButton, timespanLabel, tripOptionLabel;

- (id)init {
	
    if ((self = [super init])) {
		
		int barHeight = 46;
		int buttonWidth = 75;
		
		self.frame = CGRectMake(0, -barHeight, 320, barHeight);
		self.alpha = 0.8;
		
		CGRect timespanLabelFrame = CGRectMake(buttonWidth+1, barHeight-27, 320-2*buttonWidth-2, barHeight/2);
		CGRect tripOptionLabelFrame = CGRectMake(buttonWidth+1, 1, 320-2*buttonWidth-2, barHeight/2);
		
		//SETUP BACKGROUND IMAGE
		UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-bar-background-tile.png"]];
		backgroundImageView.frame = CGRectMake(buttonWidth+1, 0, 320-2*buttonWidth-2, barHeight);
		backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:backgroundImageView];
		[backgroundImageView release];
		
		//TRIP OPTION LABEL
		tripOptionLabel = [[UILabel alloc] initWithFrame:tripOptionLabelFrame];
		tripOptionLabel.textAlignment = UITextAlignmentCenter;
		tripOptionLabel.font = [UIFont systemFontOfSize:13];
		tripOptionLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		tripOptionLabel.textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
		tripOptionLabel.text = @"Trip 1 of 5";
		[self addSubview:tripOptionLabel];
		
		//SETUP TRIP TIMESPAN LABEL
		timespanLabel = [[UILabel alloc] initWithFrame:timespanLabelFrame];
		timespanLabel.textAlignment = UITextAlignmentCenter;
		timespanLabel.font = [UIFont boldSystemFontOfSize:15];
		timespanLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		timespanLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		timespanLabel.text = @"8:55 pm ➞ 9:47 pm";
		[self addSubview:timespanLabel];
		
		//SETUP NEXT/PREV BUTTONS
		previousTripButton = [UIButton buttonWithType:UIButtonTypeCustom];
		previousTripButton.frame = CGRectMake(0, 0, buttonWidth, barHeight);
		previousTripButton.clipsToBounds = YES;
		[previousTripButton setImage:[UIImage imageNamed:@"prev-trip-button-enabled.png"] forState:UIControlStateNormal];
		[previousTripButton setImage:[UIImage imageNamed:@"prev-trip-button-disabled.png"] forState:UIControlStateDisabled];
		[previousTripButton setImage:[UIImage imageNamed:@"prev-trip-button-highlighted.png"] forState:UIControlStateHighlighted];
		[previousTripButton addTarget:self action:@selector(previousTripButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:previousTripButton];
		
		//SETUP NEXT/PREV BUTTONS
		nextTripButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nextTripButton.frame = CGRectMake(320-buttonWidth, 0, buttonWidth, barHeight);
		nextTripButton.clipsToBounds = YES;
		[nextTripButton setImage:[UIImage imageNamed:@"next-trip-button-enabled.png"] forState:UIControlStateNormal];
		[nextTripButton setImage:[UIImage imageNamed:@"next-trip-button-disabled.png"] forState:UIControlStateDisabled];
		[nextTripButton setImage:[UIImage imageNamed:@"next-trip-button-highlighted.png"] forState:UIControlStateHighlighted];
		[nextTripButton addTarget:self action:@selector(nextTripButtonTapped) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:nextTripButton];
	
    }
	
    return self;
}

- (void) nextTripButtonTapped {
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"nextTripButtonTapped" object:nil];
	
}

- (void) previousTripButtonTapped {

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"previousTripButtonTapped" object:nil];
	
}

- (void)drawRect:(CGRect)rect {
	
	// Drawing code
}


- (void)dealloc {
    
	[tripOptionLabel release];
	[timespanLabel release];
	
	[super dealloc];
}


@end
