//
// Leg.m
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "DataHelper.h"
#import "TransitLeg.h"

@implementation TransitLeg

@synthesize agency, route, directions, vehicleId, startStop, endStop, startDate, endDate, timeToTransfer;

- (id) init {

	if (self = [super init]) timeToTransfer = kTimeToTransferNoTransfer;
	return(self);

}

// set the bart transit info for this leg
- (void) setBartTransitInfoWithDirectionTitle:(NSString *)dirTitle destinationStopTag:(NSString *)destinationStopTag stopTitle:(NSString *)stopTitle {
	self.agency = [DataHelper agencyWithShortTitle:@"bart"];
	self.startStop = [DataHelper bartStopWithName:stopTitle];
	self.directions = [NSMutableArray arrayWithArray:[DataHelper bartDirectionsWithTitle:dirTitle]];
	self.route = [[self.directions objectAtIndex:0] route];
}

// set the transit direction and start stop for this leg
- (void) setTransitInfoWithAgencyShortTitle:(NSString *)agencyShortTitle routeTag:(NSString *)routeTag directionTag:(NSString *)dirTag stopTag:(NSString *)stopTag vehicleId:(NSString *)vehicleIdString {

	self.agency = [DataHelper agencyWithShortTitle:agencyShortTitle];
	self.route = [DataHelper routeWithTag:routeTag inAgency:agency];
	self.directions = [NSMutableArray arrayWithObject:[DataHelper directionWithTag:dirTag inRoute:route]];
	self.vehicleId = vehicleIdString;
	self.startStop = [DataHelper stopWithTag:stopTag inDirection:[self.directions objectAtIndex:0]];

}

- (void) setEndStopWithTag:(NSString *)stopTag {

	self.endStop = [DataHelper stopWithTag:stopTag inDirection:[directions objectAtIndex:0]];

}


@end
