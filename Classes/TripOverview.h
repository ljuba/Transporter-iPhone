//
// TripOverview.h
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface TripOverview : UIViewController <CLLocationManagerDelegate> {

	UIButton *earlierTripButton;
	UIButton *nextTripButton;

	UILabel *tripTime;
	UILabel *tripDuration;

	MKMapView *map;

	CLLocationManager *locationManager;

	NSDictionary *tripRequest;

}

@property (nonatomic, retain) IBOutlet UIButton *earlierTripButton;
@property (nonatomic, retain) IBOutlet UIButton *nextTripButton;

@property (nonatomic, retain) IBOutlet UILabel *tripTime;
@property (nonatomic, retain) IBOutlet UILabel *tripDuration;

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) NSDictionary *tripRequest;

@end
