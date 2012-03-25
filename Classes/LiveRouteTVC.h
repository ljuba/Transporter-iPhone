//
// LiveRouteTVC.h
// kronos
//
// Created by Ljuba Miljkovic on 3/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Direction.h"
#import "VehicleFetcher.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#define kLiveRouteRowHeight 30

@interface LiveRouteTVC : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate> {

	NSMutableArray *stops;
	Direction *direction;

	UILabel *label;

	CLLocationManager *locationManager;

	UIButton *userMarker;

	UITableView *_tableView;

	Stop *startingStop;             // the stop you reach this screen from
	Stop *scrollStop;               // the stop to scroll to when you tap the scroll button

	Stop *tappedStop;               // the stop you tap to learn about your eta

	NSTimer *locationFixTimeoutTimer;

	int locationAccuracy;

	VehicleFetcher *vehicleFetcher;
	NSMutableDictionary *predictions;

	NSString *vehicleID;

	BOOL isBART;

	Stop *savedNextStop;
	Stop *savedPreviousStop;                // used when location hasn't changed between location updates

}

@property (nonatomic, strong) NSMutableArray *stops;
@property (nonatomic, strong) Direction *direction;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIButton *userMarker;
@property (nonatomic, strong) IBOutlet UITableView *_tableView;
@property (nonatomic, strong) IBOutlet UILabel *label;

@property (nonatomic, strong) Stop *startingStop;
@property (nonatomic, strong) Stop *scrollStop;
@property (nonatomic, strong) Stop *tappedStop;

@property (nonatomic, strong) Stop *savedNextStop;
@property (nonatomic, strong) Stop *savedPreviousStop;

@property (nonatomic, strong) NSTimer *locationFixTimeoutTimer;

@property int locationAccuracy;

@property (nonatomic, strong) VehicleFetcher *vehicleFetcher;
@property (nonatomic, strong) NSMutableDictionary *predictions;

@property (nonatomic, strong) NSString *vehicleID;

@property BOOL isBART;

- (void) positionUserMarkerToNewLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void) scrollToStopAnimated:(BOOL)animated;
- (void) giveupLocationFix;
- (void) findLocation;

- (void) fetchVehicles;
- (void) didReceiveVehicles:(NSMutableArray *)vehicles;
- (NSString *) matchingVehicleID:(NSMutableArray *)vehicles;

- (void) fetchPredictions;
- (void) didReceivePredictions:(NSMutableDictionary *)predictions;

@end
