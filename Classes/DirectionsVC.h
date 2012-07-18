//
// DirectionsVC.h
// kronos
//
// Created by Ljuba Miljkovic on 3/15/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Direction.h"
#import "Route.h"
#import "StopsTVC.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NewDirectionAnnotationView.h"

@interface DirectionsVC : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, NewDirectionAnnotationViewDelegate> 

@property (nonatomic, strong) NSArray *directions;
@property (nonatomic, strong) Route *route;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void) directionSelected:(NSNotification *)note;

@end
