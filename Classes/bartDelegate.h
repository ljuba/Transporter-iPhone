//
// bartDelegate.h
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Agency.h"
#import "Route.h"
#import "Stop.h"
#import "TransitDelegate.h"
#import <Foundation/Foundation.h>

@interface bartDelegate : TransitDelegate {}

// store the closest stop in a static varible so it can be accessed even after you switch agencies in the LinesVC
+ (NSMutableArray *) closestStops;
+ (void) setClosestStops:(NSMutableArray *)_closestStops;

- (id) initWithAgency:(Agency *)agency;
- (void) setContentsForBartAgency:(Agency *)bartAgency;
- (void) displayClosestStopToLocation:(CLLocation *)location;
@end
