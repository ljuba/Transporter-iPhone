//
//  DataImporter.h
//  BATransit
//
//  Created by Ljuba Miljkovic on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kronosAppDelegate.h"
#import "TouchXML.h"

#import <CoreData/CoreData.h>
#import "Route.h"
#import "Agency.h"
#import "Direction.h"
#import "Stop.h"



@interface DataImporter : NSObject {
	
}

+ (void)importTransitData;
//+ (NSArray *)pathForLine:(NSString *)agency routeTag:(NSString *)line;
@end
