//
// DirectionsVC.h
// kronos
//
// Created by Ljuba Miljkovic on 3/15/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Direction.h"
#import "DirectionAnnotationView.h"
#import "Route.h"
#import "StopsTVC.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface DirectionsVC : UIViewController <CLLocationManagerDelegate> 

@property (nonatomic, strong) NSArray *directions;
@property (nonatomic, strong) Route *route;

@property (nonatomic, strong) IBOutlet UIImageView *routeMap;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property CLLocationCoordinate2D centerCoordinate;  // used to position the user location on the static map
@property int zoomLevel;    // used to position the user location on the static map
@property int yCropPixels;  // used to position the user location on the static map

@property ( nonatomic) IBOutlet UIImageView *googleLogo;

- (void) directionSelected:(NSNotification *)note;
- (void) toggleLocationUpdating:(NSNotification *)note;

@end
