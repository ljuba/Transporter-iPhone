//
// Trip.m
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TransitLeg.h"
#import "Trip.h"
#import "WalkingLeg.h"

@implementation Trip

@synthesize legs, startTitle, endTitle, cost, duration;

- (id) init {

	if (self = [super init]) self.legs = [NSMutableArray array];
	return(self);

}

- (NSString *) durationLabelText {

	int tripTotalMinutes = round(duration / 60);
	int tripHours = floor(tripTotalMinutes / 60);
	int tripMinutes = tripTotalMinutes - tripHours * 60;

	return([NSString stringWithFormat:@"%dh %dm", tripHours, tripMinutes]);

}

- (NSString *) costLabelText {

	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[formatter setCurrencySymbol:@"$"];
	[formatter setMaximumFractionDigits:2];

	// NSString *formattedCost = [formatter stringFromNumber:[NSNumber numberWithDouble:cost/100]];
	[formatter release];

	return(@"");
	// return formattedCost;

}

// infer start/end times from the trip legs
- (void) processData {

	NSDate *startDate;
	NSDate *endDate;

	// SET THE START TIME FOR THE INITIAL WALKING LEG
	id firstLeg = [legs objectAtIndex:0];

	if ([firstLeg isMemberOfClass:[WalkingLeg class]]) {

		WalkingLeg *walkingLeg = (WalkingLeg *)firstLeg;
		TransitLeg *nextLeg = [legs objectAtIndex:1];

		NSTimeInterval interval = walkingLeg.duration;
		NSDate *date = nextLeg.startDate;

		walkingLeg.date = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:date] autorelease];

		walkingLeg.destinationTitle = nextLeg.startStop.title;

		// set trip start date
		startDate = walkingLeg.date;

	} else {

		TransitLeg *transitLeg = (TransitLeg *)firstLeg;
		startDate = transitLeg.startDate;
	}
	// SET THE START TIME FOR THE FINAL WALKING LEG
	id lastLeg = [legs lastObject];

	if ([lastLeg isMemberOfClass:[WalkingLeg class]]) {

		WalkingLeg *walkingLeg = (WalkingLeg *)lastLeg;
		TransitLeg *previousLeg = [legs objectAtIndex:[legs count] - 2];

		NSTimeInterval interval = walkingLeg.duration;
		NSDate *date = previousLeg.endDate;

		walkingLeg.date = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:date] autorelease];

		walkingLeg.destinationTitle = endTitle;

		// set trip end date
		endDate = walkingLeg.date;

	} else {

		TransitLeg *transitLeg = (TransitLeg *)lastLeg;
		endDate = transitLeg.endDate;
	}
	// SET TRIP DURATION
	duration = [endDate timeIntervalSinceDate:startDate];

	// REMOVE ANY WALKING LEGS FROM THE MIDDLE OF THE TRIP

	NSMutableArray *finalLegs = [NSMutableArray array];

	for (id leg in legs) {

		[finalLegs addObject:leg];

		if ([leg isMemberOfClass:[WalkingLeg class]]) {

			int legIndex = [legs indexOfObject:leg];

			if ( (legIndex != 0)&&(legIndex != [legs count] - 1) ) [finalLegs removeLastObject];
		}
	}
	self.legs = finalLegs;

	// SET THE TRANSFER TIMES

	for (id leg in legs) {

		int legIndex = [legs indexOfObject:leg];

		// make sure it's a transit leg and not the last leg
		if ( [leg isMemberOfClass:[TransitLeg class]]&&(legIndex != [legs count] - 1) ) {

			TransitLeg *transitLeg = (TransitLeg *)leg;

			id nextLeg = [legs objectAtIndex:legIndex + 1];

			// make sure the next leg is a transit leg aswell and set it's transfer time
			if ([nextLeg isMemberOfClass:[TransitLeg class]]) {
				TransitLeg *nextTransitLeg = (TransitLeg *)nextLeg;

				NSTimeInterval transferTime = [nextTransitLeg.startDate timeIntervalSinceDate:transitLeg.endDate];

				nextTransitLeg.timeToTransfer = transferTime;

			}
		}
	}
}

- (void) printDescription {

	NSLog(@"\n"); /* DEBUG LOG */

	for (id leg in legs) {

		if ([leg isMemberOfClass:[WalkingLeg class]]) {

			WalkingLeg *walkingLeg = (WalkingLeg *)leg;

			NSLog(@" -Walking Leg"); /* DEBUG LOG */
			NSLog(@"  Start: %f, %f", walkingLeg.startLocationCoordinate.latitude, walkingLeg.startLocationCoordinate.longitude); /* DEBUG LOG */
			NSLog(@"  End: %f, %f", walkingLeg.endLocationCoordinate.latitude, walkingLeg.endLocationCoordinate.longitude); /* DEBUG LOG */
			NSLog(@"  Duration: %f", walkingLeg.duration / 60); /* DEBUG LOG */
		} else {

			TransitLeg *transitLeg = (TransitLeg *)leg;

			NSLog(@" -Transit Leg"); /* DEBUG LOG */
			NSLog(@"  Agency: %@", transitLeg.agency.shortTitle); /* DEBUG LOG */
			NSLog(@"  Route: %@", transitLeg.route.tag); /* DEBUG LOG */
			NSLog(@"  Vehicle ID: %@", transitLeg.vehicleId); /* DEBUG LOG */

			if ( (transitLeg.directions != nil)&&([transitLeg.directions count] > 0) ) NSLog(@"  Direction: %@", [(Direction *)[transitLeg.directions objectAtIndex:0] tag]);  /* DEBUG LOG */
			NSLog(@"  %@ -> %@", transitLeg.startStop.tag, transitLeg.endStop.tag); /* DEBUG LOG */
		}
	}
}

- (void) dealloc {
	[legs release];
	[startTitle release];
	[endTitle release];

	[super dealloc];
}

@end
