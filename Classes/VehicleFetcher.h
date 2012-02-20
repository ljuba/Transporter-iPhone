//
// VehicleFetcher.h
// transporter
//
// Created by Ljuba Miljkovic on 5/8/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Agency.h"
#import "Direction.h"
#import "Route.h"
#import "TouchXML.h"
#import <Foundation/Foundation.h>

@interface VehicleFetcher : NSObject {}

- (void) fetchVehiclesForDirection:(Direction *)direction;

@end
