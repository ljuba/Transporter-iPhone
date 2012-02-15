//
//  VehicleFetcher.h
//  transporter
//
//  Created by Ljuba Miljkovic on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Direction.h"
#import "Route.h"
#import "Agency.h"
#import "TouchXML.h"

@interface VehicleFetcher : NSObject {

}

- (void)fetchVehiclesForDirection:(Direction *)direction;

@end
