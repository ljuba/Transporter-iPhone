//
// Leg.h
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Agency.h"
#import "Direction.h"
#import "Route.h"
#import "Stop.h"
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface TransitLeg : NSObject {

	Agency *agency;
	Route *route;

	// There are multiple directions for BART TransitLegs
	// but only one direction for NextBus TransitLegs
	// because multiple BART directions can run through
	// the Start/End stop of a leg
	NSMutableArray *directions;
	NSString *vehicleId;

	Stop *startStop;
	Stop *endStop;

	NSDate *startDate;
	NSDate *endDate;

	NSTimeInterval timeToTransfer;
}

@property (nonatomic) Agency *agency;
@property (nonatomic) Route *route;
@property (nonatomic) NSMutableArray *directions;
@property (nonatomic) NSString *vehicleId;

@property (nonatomic) Stop *startStop;
@property (nonatomic) Stop *endStop;

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@property (nonatomic) NSTimeInterval timeToTransfer;

- (void) setBartTransitInfoWithDirectionTitle:(NSString *)dirTag destinationStopTag:(NSString *)destinationStopTag stopTitle:(NSString *)stopTitle;
- (void) setTransitInfoWithAgencyShortTitle:(NSString *)agencyShortTitle routeTag:(NSString *)routeTag directionTag:(NSString *)dirTag stopTag:(NSString *)stopTag vehicleId:(NSString *)vehicleId;
- (void) setEndStopWithTag:(NSString *)stopTag;

@end
