//
// DataImporter.h
// BATransit
//
// Created by Ljuba Miljkovic on 11/17/09.
// Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TouchXML.h"
#import "kronosAppDelegate.h"
#import <UIKit/UIKit.h>

#import "Agency.h"
#import "Direction.h"
#import "Route.h"
#import "Stop.h"
#import <CoreData/CoreData.h>

@interface DataImporter : NSObject {}

+ (void) importTransitData;
// + (NSArray *)pathForLine:(NSString *)agency routeTag:(NSString *)line;
@end
