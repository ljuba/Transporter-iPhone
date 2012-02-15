//
//  StopsTVC.h
//  BATransit
//
//  Created by Ljuba Miljkovic on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "kronosAppDelegate.h"
#import "NextBusStopDetails.h"
#import <CoreLocation/CoreLocation.h>

#import <CoreData/CoreData.h>
#import "Direction.h"
#import "Route.h"
#import "Stop.h"

@interface StopsTVC : UITableViewController <CLLocationManagerDelegate>{

	NSMutableArray *stops;
	Direction *direction;
	
	CLLocationManager *locationManager;
	
}

@property (nonatomic, retain) NSMutableArray *stops;
@property (nonatomic, retain) Direction *direction;

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)displayClosestStopToLocation:(CLLocation *)location;
- (void)toggleLocationUpdating:(NSNotification *)note;

@end
