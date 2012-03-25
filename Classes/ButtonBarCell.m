//
// ButtonBarCell.m
//
// Created by Ljuba Miljkovic on 3/16/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ButtonBarCell.h"

@implementation ButtonBarCell

@synthesize nextStopButton, previousStopButton, liveRouteButton, direction, stop, nextStop, previousStop;

- (IBAction) goToPreviousStop:(id)sender {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"goToPreviousStop" object:self];
}

- (IBAction) goToNextStop:(id)sender {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"goToNextStop" object:self];
}

- (IBAction) loadLiveRoute:(id)sender {
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter postNotificationName:@"loadLiveRoute" object:self];
}

// configure whether next/prev/switch buttons are active or not
- (void) configureButtons {

	self.nextStopButton.enabled = [self thereIsNextStop];
	self.previousStopButton.enabled = [self thereIsPreviousStop];

}

- (BOOL) thereIsNextStop {

	NSArray *stopOrder = self.direction.stopOrder;
	NSString *stopTag = [NSString stringWithFormat:@"%@", self.stop.tag];

	// if this is the last stop in the direction, the button should be disabled
	if ([[stopOrder lastObject] isEqual:stopTag]) return(NO);
	else {

		int indexOfNextStop = [stopOrder indexOfObject:stopTag] + 1;

		NSString *nextStopTag = [NSString stringWithFormat:@"%@", [stopOrder objectAtIndex:indexOfNextStop]];
		NSLog(@"Current Stop: %@", stopTag); /* DEBUG LOG */
		NSLog(@"Next Stop: %@", nextStopTag); /* DEBUG LOG */

		NSMutableSet *stops = [NSMutableSet setWithSet:self.direction.stops];

		// filter all but the next stop
		NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"tag == %@", nextStopTag];
		[stops filterUsingPredicate:filterPredicate];

		self.nextStop = [stops anyObject];

		return(YES);
	}
}

- (BOOL) thereIsPreviousStop {

	NSArray *stopOrder = self.direction.stopOrder;
	NSString *stopTag = [NSString stringWithFormat:@"%@", self.stop.tag];

	// if this is the first stop in the direction, the button should be disabled
	if ([[stopOrder objectAtIndex:0] isEqual:stopTag]) return(NO);
	else {

		NSString *previousStopTag = [NSString stringWithFormat:@"%@", [stopOrder objectAtIndex:[stopOrder indexOfObject:stopTag] - 1]];
		NSLog(@"Current Stop: %@", stopTag); /* DEBUG LOG */
		NSLog(@"Previous Stop: %@", previousStopTag); /* DEBUG LOG */

		NSMutableSet *stops = [NSMutableSet setWithSet:self.direction.stops];

		// filter all but the next stop
		NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"tag == %@", previousStopTag];
		[stops filterUsingPredicate:filterPredicate];

		self.previousStop = [stops anyObject];

		return(YES);
	}
}

@end
