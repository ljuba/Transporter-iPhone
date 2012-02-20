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

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *recenterButton;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *previousStopAnnotations;

@property BOOL autoRecenterMap;

- (IBAction) recenterMap;
- (NSMutableArray *) getStopAnnotationsForRegion:(MKCoordinateRegion)region;
- (void) toggleLocationUpdating:(NSNotification *)note;

@end
