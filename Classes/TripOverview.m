//
//  TripOverview.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripOverview.h"
#import "TripFetcher.h"

@implementation TripOverview

@synthesize earlierTripButton, nextTripButton, tripTime, tripDuration, locationManager, map, tripRequest;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Overview";
	
	//setup start trip button
	UIBarButtonItem *startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleDone target:nil action:nil];
	startButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = startButton;
	[startButton release];
	
	//setup core location
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
}

//perform once the view loads
- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];	
	[locationManager startUpdatingLocation];
	
	//fetch trips for the request passed from the trip input screen
	[TripFetcher fetchTripsForRequest:tripRequest];
	
}

//stop the automatic fetching of predictions once the view is gone
- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	[locationManager stopUpdatingLocation];
	
}





#pragma mark -
#pragma mark Memory


- (void)viewDidUnload {
	
	self.earlierTripButton = nil;
	self.nextTripButton = nil;
	self.tripTime = nil;
	self.tripDuration = nil;
	self.map = nil;
}


- (void)dealloc {
	[tripRequest release];
    [locationManager release];
	[super dealloc];
}


@end
