//
//  TripPlanner.h
//  kronos
//
//  Created by Ljuba Miljkovic on 4/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TripOverviewBottomBar.h"
#import "TripOverviewTopBar.h"
#import "TripInputView.h"
#import "TripFetcher.h"

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

@property (nonatomic, retain) TripOverviewBottomBar *bottomBar;
@property (nonatomic, retain) TripOverviewTopBar *topBar;

@property (nonatomic, retain) UIControl *mapOverlay;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, retain) IBOutlet TripInputView *inputView;
@property (nonatomic, retain) IBOutlet UITextField *startField;
@property (nonatomic, retain) IBOutlet UITextField *endField;
@property (nonatomic, retain) IBOutlet UIButton *changeTimeButton;
@property (nonatomic, retain) IBOutlet UIButton *switchFieldsButton;

@property (nonatomic, retain) TripFetcher *tripFetcher;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, retain) NSArray *trips;
@property (nonatomic, retain) Trip *selectedTrip;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@property (nonatomic, retain) UIActivityIndicatorView *tripFetchSpinner;

- (IBAction)switchFieldsContents;
- (void)cancelTrip;
- (void)editTrip;
- (void)setRouteButtonStatus;

- (void)setupTripOverview:(NSArray *)fetchedTrips;
- (void)startTrip;

- (void)displayTripOverview;

- (void)setupMapForTrip;

- (void)showNextTrip;
- (void)showPreviousTrip;

- (void)routeTrip;
- (void)reportRoutingError:(NSError *)error;

@end
