//
// NearMeVC.h
// kronos
//
// Created by Ljuba Miljkovic on 3/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

#import "BartStopDetails.h"
#import "NextBusStopDetails.h"

@interface NearMeVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {

	MKMapView *mapView;
	UIBarButtonItem *recenterButton;

	CLLocationManager *locationManager;

	NSMutableArray *previousStopAnnotations;

	BOOL autoRecenterMap;

}

@property (nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) IBOutlet UIBarButtonItem *recenterButton;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableArray *previousStopAnnotations;

@property BOOL autoRecenterMap;

- (IBAction) recenterMap;
- (NSMutableArray *) getStopAnnotationsForRegion:(MKCoordinateRegion)region;
- (void) toggleLocationUpdating:(NSNotification *)note;

@end
