//
// TripPlanner.h
// kronos
//
// Created by Ljuba Miljkovic on 4/20/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripFetcher.h"
#import "TripInputView.h"
#import "TripOverviewBottomBar.h"
#import "TripOverviewTopBar.h"
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface TripPlannerVC : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {

	UITextField *startField;
	UITextField *endField;
	UIButton *switchFieldsButton;

	UIButton *changeTimeButton;

	UIControl *mapOverlay;
	MKMapView *mapView;

	TripInputView *inputView;

	TripOverviewBottomBar *bottomBar;
	TripOverviewTopBar *topBar;

	TripFetcher *tripFetcher;

	CLLocationManager *locationManager;

	NSArray *trips;
	Trip *selectedTrip;

	NSDateFormatter *dateFormatter;

	UIActivityIndicatorView *tripFetchSpinner;
	
}

@property (nonatomic) TripOverviewBottomBar *bottomBar;
@property (nonatomic) TripOverviewTopBar *topBar;

@property (nonatomic) UIControl *mapOverlay;
@property (nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) IBOutlet TripInputView *inputView;
@property (nonatomic) IBOutlet UITextField *startField;
@property (nonatomic) IBOutlet UITextField *endField;
@property (nonatomic) IBOutlet UIButton *changeTimeButton;
@property (nonatomic) IBOutlet UIButton *switchFieldsButton;

@property (nonatomic) TripFetcher *tripFetcher;

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) NSArray *trips;
@property (nonatomic) Trip *selectedTrip;
@property (nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) UIActivityIndicatorView *tripFetchSpinner;

- (IBAction) switchFieldsContents;
- (void) cancelTrip;
- (void) editTrip;
- (void) setRouteButtonStatus;

- (void) setupTripOverview:(NSArray *)fetchedTrips;
- (void) startTrip;

- (void) displayTripOverview;

- (void) setupMapForTrip;

- (void) showNextTrip;
- (void) showPreviousTrip;

- (void) routeTrip;
- (void) reportRoutingError:(NSError *)error;

@end
