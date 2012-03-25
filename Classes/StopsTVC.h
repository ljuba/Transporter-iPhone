//
// StopsTVC.h
// BATransit
//
// Created by Ljuba Miljkovic on 11/10/09.
// Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NextBusStopDetails.h"
#import "kronosAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "Direction.h"
#import "Route.h"
#import "Stop.h"
#import <CoreData/CoreData.h>

@interface StopsTVC : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *stops;
@property (nonatomic, strong) Direction *direction;

@property (nonatomic, strong) CLLocationManager *locationManager;

- (void) displayClosestStopToLocation:(CLLocation *)location;
- (void) toggleLocationUpdating:(NSNotification *)note;

@end
