//
// TripPlanner.m
// kronos
//
// Created by Ljuba Miljkovic on 4/20/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "CustomButton.h"
#import "DataHelper.h"
#import "Direction.h"
#import "Route.h"
#import "StopAnnotation.h"
#import "TransitLeg.h"
#import "TripDetailsTVC.h"
#import "TripFetcher.h"
#import "TripOverviewMapDelegate.h"
#import "TripPlannerVC.h"
#import "WalkingLeg.h"
#import <QuartzCore/QuartzCore.h>

@implementation TripPlannerVC

@synthesize startField, endField, changeTimeButton, switchFieldsButton, mapView, inputView, trips, dateFormatter, selectedTrip;
@synthesize bottomBar, topBar, mapOverlay, tripFetcher, locationManager, tripFetchSpinner;

- (void) viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.title = @"Trip Planner";

	trips = [[NSMutableArray alloc] init];
	startField.delegate = self;
	endField.delegate = self;

	// SETUP "CANCEL" BUTTON
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTrip)];
	self.navigationItem.leftBarButtonItem = cancelButton;

	// SETUP "ROUTE" BUTTON
	CustomButton *blueButton = [[CustomButton alloc] initWithColor:@"blue"];
	[blueButton setTitle:@"Route" forState:UIControlStateNormal];
	[blueButton addTarget:self action:@selector(routeTrip) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:blueButton];
	button.enabled = NO;
	self.navigationItem.rightBarButtonItem = button;


	// SETUP BACK BUTTON
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;

	// fixes blurry text bug to have the fields be 32px high
	startField.frame = CGRectMake(startField.frame.origin.x, startField.frame.origin.y, startField.frame.size.width, 32);
	endField.frame = CGRectMake(endField.frame.origin.x, endField.frame.origin.y, endField.frame.size.width, 32);

	// SETUP TEXT FIELD PROMPTS
	CGRect promptRect = CGRectMake(startField.frame.origin.x, startField.frame.origin.y, 32, startField.frame.size.height);

	UILabel *startPrompt = [[UILabel alloc] initWithFrame:promptRect];
	startPrompt.text = @"Start:";
	startPrompt.font = [UIFont systemFontOfSize:13];
	startPrompt.textAlignment = UITextAlignmentRight;
	startPrompt.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	startPrompt.backgroundColor = [UIColor colorWithWhite:0 alpha:0];

	startField.leftViewMode = UITextFieldViewModeAlways;
	startField.leftView = startPrompt;

	UILabel *endPrompt = [[UILabel alloc] initWithFrame:promptRect];
	endPrompt.text = @"End:";
	endPrompt.textAlignment = UITextAlignmentRight;
	endPrompt.font = [UIFont systemFontOfSize:13];
	endPrompt.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	endPrompt.backgroundColor = [UIColor colorWithWhite:0 alpha:0];

	endField.leftViewMode = UITextFieldViewModeAlways;
	endField.leftView = endPrompt;

	// SETUP INITIAL TEXT FIELD CONDITIONS
	// startField.text = @"1 Post St, SF";
	// endField.text = @"19 Caine Ave., SF";
	[endField becomeFirstResponder];

	// SETUP OVERVIEW BARS
	bottomBar = [[TripOverviewBottomBar alloc] init];
	bottomBar.hidden = YES;
	[self.view addSubview:bottomBar];

	topBar = [[TripOverviewTopBar alloc] init];
	[self.view insertSubview:topBar atIndex:1];

	// SETUP MAP OVERLAY
	mapOverlay = [[UIControl alloc] initWithFrame:self.view.bounds];
	mapOverlay.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
	[mapOverlay addTarget:self action:@selector(cancelTrip) forControlEvents:UIControlEventTouchDown];
	[self.view insertSubview:mapOverlay atIndex:1];

	// SETUP NOTIFICATION OBSERVER
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(showNextTrip) name:@"nextTripButtonTapped" object:nil];
	[nc addObserver:self selector:@selector(showPreviousTrip) name:@"previousTripButtonTapped" object:nil];

	// SETUP TRIP FETCHER
	tripFetcher = [[TripFetcher alloc] init];

	// SETUP TRIP FETCH SPINNER
	tripFetchSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	tripFetchSpinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height * 0.45);
	tripFetchSpinner.hidesWhenStopped = YES;
	tripFetchSpinner.hidden = YES;
	[self.view addSubview:tripFetchSpinner];

	// SETUP DATE FORMATTER
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setPMSymbol:@"pm"];
	[dateFormatter setAMSymbol:@"am"];

	// SETUP LOCATION MANAGER
	locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];

	// SETUP MAP VIEW
	MKCoordinateRegion region;
	CLLocationCoordinate2D center;
	center.latitude = 37.759859;
	center.longitude = -122.226334;
	region.span.latitudeDelta = 1;
	region.span.longitudeDelta = 1;

	region.center = center;

	[mapView setRegion:region animated:NO];
	[mapView regionThatFits:region];

    
    //DON'T KNOW WHAT'S UP WITH THESE LINES OF CODE
	//mapDelegate = [[TripOverviewMapDelegate alloc] init];
	//mapView.delegate = mapDelegate;

}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

- (void) viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];

}

#pragma mark -
#pragma mark Routing

- (void) reportRoutingError:(NSError *)error {

	// hide trip fetching activity indicator
	[tripFetchSpinner stopAnimating];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Find Trips" message:[error.userInfo valueForKey:@"message"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[alert show];


}

// shows the keyboard when the "Dismiss" button is tapped in the error alert view
- (void) alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {

	[endField becomeFirstResponder];

}

// responds to user tapping "Route"
- (void) setupTripOverview:(NSArray *)fetchedTrips {

	// hide trip fetching activity indicator
	[tripFetchSpinner stopAnimating];

	self.trips = fetchedTrips;

	selectedTrip = [trips objectAtIndex:0];

	self.navigationItem.title = @"Overview";

	[endField resignFirstResponder];
	[startField resignFirstResponder];

	// SET PREV TRIP BUTTON TO DISSABLED
	topBar.previousTripButton.enabled = NO;
	topBar.nextTripButton.enabled = YES;

	// MOVE THE INPUTVIEW AWAY
	[UIView beginAnimations:nil context:nil];

	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(setupOverview)];

	CGRect newFrame = CGRectMake(0, -inputView.frame.size.height, inputView.frame.size.width, inputView.frame.size.height);
	inputView.frame = newFrame;

	[UIView commitAnimations];

	// HIDE THE MAP OVERLAY
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	mapOverlay.alpha = 0;
	[UIView commitAnimations];

	// SETUP EDIT BUTTON
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTrip)];
	self.navigationItem.leftBarButtonItem = editButton;

	// SETUP THE START TRIP BUTTON
	CustomButton *startButton = [[CustomButton alloc] initWithColor:@"green"];
	[startButton setTitle:@"Start" forState:UIControlStateNormal];
	[startButton addTarget:self action:@selector(startTrip) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:startButton];
	self.navigationItem.rightBarButtonItem = button;


	// SHOW OVERVIEW BARS
	bottomBar.hidden = NO;

	// MOVE THE OVERVIEW TOP BAR INTO VIEW
	[UIView beginAnimations:nil context:nil];

	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];

	CGRect newTopBarFrame = CGRectMake(0, 0, topBar.frame.size.width, topBar.frame.size.height);
	topBar.frame = newTopBarFrame;

	[UIView commitAnimations];

	[self displayTripOverview];

}

- (void) showNextTrip {

	int previousSelectedTripIndex = [trips indexOfObject:selectedTrip];

	selectedTrip = [trips objectAtIndex:previousSelectedTripIndex + 1];

	if (previousSelectedTripIndex + 1 == [trips count] - 1) topBar.nextTripButton.enabled = NO;
	else topBar.nextTripButton.enabled = YES;
	// the previousTripButton will always be enabled after you tap the nextTripButton
	topBar.previousTripButton.enabled = YES;

	[self displayTripOverview];

}

- (void) showPreviousTrip {

	int previousSelectedTripIndex = [trips indexOfObject:selectedTrip];

	selectedTrip = [trips objectAtIndex:previousSelectedTripIndex - 1];

	if (previousSelectedTripIndex - 1 == 0) topBar.previousTripButton.enabled = NO;
	else topBar.previousTripButton.enabled = YES;
	// the nextTripButton will always be enabled after you tap the previousTripButton
	topBar.nextTripButton.enabled = YES;

	[self displayTripOverview];

}

- (void) displayTripOverview {

	// GATHER THE TRIPS
	WalkingLeg *startLeg = (WalkingLeg *)[selectedTrip.legs objectAtIndex:0];
	NSString *startTime = [dateFormatter stringFromDate:startLeg.date];

	WalkingLeg *endLeg = (WalkingLeg *)[selectedTrip.legs lastObject];
	NSString *endTime = [dateFormatter stringFromDate:endLeg.date];

	topBar.timespanLabel.text = [NSString stringWithFormat:@"%@ ➙ %@", startTime, endTime];

	// SET TRIP NUMBER
	int tripNumber = [trips indexOfObject:selectedTrip] + 1;
	topBar.tripOptionLabel.text = [NSString stringWithFormat:@"Trip %d of %d", tripNumber, [trips count]];

	// SET TRIP TOTAL TIME
	bottomBar.trip = selectedTrip;

	[self setupMapForTrip];

}

// set the map region based on the start/end points of the trip
- (void) setupMapForTrip {

	CLLocationCoordinate2D startLocation = [[selectedTrip.legs objectAtIndex:0] startLocationCoordinate];

	// TODO: get coordinate for destination, not just the starting coordinate of the last leg
	CLLocationCoordinate2D endLocation = [[selectedTrip.legs lastObject] startLocationCoordinate];

	CLLocationCoordinate2D center;
	center.latitude = (startLocation.latitude + endLocation.latitude) / 2;
	center.longitude = (startLocation.longitude + endLocation.longitude) / 2;

	MKCoordinateSpan span;
	span.latitudeDelta = fabs(startLocation.latitude - center.latitude) * 2.7;
	span.longitudeDelta = fabs(startLocation.longitude - center.longitude) * 2.7;

	MKCoordinateRegion region;
	region.span = span;
	region.center = center;

	[mapView setRegion:region animated:YES];
	[mapView regionThatFits:region];

	// ADD MAP ANNOTATIONS

	[mapView removeAnnotations:[mapView annotations]];

	NSMutableArray *legs = selectedTrip.legs;

	for (id leg in legs) {

		if ([leg isMemberOfClass:[WalkingLeg class]]) {} else {

			TransitLeg *transitLeg = (TransitLeg *)leg;

			StopAnnotation *startStopAnnotation = [[StopAnnotation alloc] initWithStop:transitLeg.startStop];
			StopAnnotation *endStopAnnotation = [[StopAnnotation alloc] initWithStop:transitLeg.endStop];

			[self.mapView addAnnotation:startStopAnnotation];
			[self.mapView addAnnotation:endStopAnnotation];

		}
	}
}

// responds to when a user has tapped the edit button from the trip overview mode
// resets things to the trip input mode
- (void) editTrip {

	self.title = @"Trip Planner";

	// MOVE THE INPUTVIEW BACK
	[UIView beginAnimations:nil context:nil];

	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(setupOverview)];

	CGRect newFrame = CGRectMake(0, 0, inputView.frame.size.width, inputView.frame.size.height);
	inputView.frame = newFrame;

	[UIView commitAnimations];

	// SHOW THE MAP OVERLAY
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	mapOverlay.alpha = 1.0;
	[UIView commitAnimations];

	// SETUP CANCEL BUTTON
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTrip)];
	self.navigationItem.leftBarButtonItem = cancelButton;

	// SETUP ROUTE BUTTON
	CustomButton *blueButton = [[CustomButton alloc] initWithColor:@"blue"];
	[blueButton setTitle:@"Route" forState:UIControlStateNormal];
	[blueButton addTarget:self action:@selector(routeTrip) forControlEvents:UIControlEventTouchUpInside];

	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:blueButton];
	button.enabled = NO;
	self.navigationItem.rightBarButtonItem = button;


	// HIDE OVERVIEW BOTTOM BAR
	bottomBar.hidden = YES;

	// MOVE THE OVERVIEW TOP BAR AWAY
	[UIView beginAnimations:nil context:nil];

	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];

	CGRect newTopBarFrame = CGRectMake(0, -topBar.frame.size.height, topBar.frame.size.width, topBar.frame.size.height);
	topBar.frame = newTopBarFrame;

	[UIView commitAnimations];

	[startField becomeFirstResponder];

}

// responds to when a user has tapped the start button and loads the trip details
- (void) startTrip {

	TripDetailsTVC *tripDetailsVC = [[TripDetailsTVC alloc] init];
	tripDetailsVC.trip = selectedTrip;
	[self.navigationController pushViewController:tripDetailsVC animated:YES];

}

#pragma mark -
#pragma mark Text Field Delegate

// As soon as either text field becomes first responder, enable the Cancel button
// Check to see if there's enough text in both fields for the "Route" button to be enabled
- (void) textFieldDidBeginEditing:(UITextField *)textField {

	self.navigationItem.leftBarButtonItem.enabled = YES;

	[self setRouteButtonStatus];
}

// Every time a character is pressed, check to see whether you should enable the "Route" button
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

	[self setRouteButtonStatus];

	return(YES);
}

// Whenever the "clear" button in either text field is pressed, disable the "Route" button
- (BOOL) textFieldShouldClear:(UITextField *)textField {

	self.navigationItem.rightBarButtonItem.enabled = NO;

	return(YES);

}

// When the return button is tapped, either move to the next field, or route the trip
- (BOOL) textFieldShouldReturn:(UITextField *)textField {

	// if you hit "return" (i.e. "next") on the start field, move on to the next field
	if (textField.tag == 0) {
		[startField resignFirstResponder];
		[endField becomeFirstResponder];

	} else [self routeTrip];
	return(YES);
}

// responds to tapping the "route" button
- (void) routeTrip {

	[self cancelTrip];              // dissable cancel button, move away keyboard

	self.navigationItem.rightBarButtonItem.enabled = NO;     // don't let users tap "route" again

	NSString *startFieldText = startField.text;
	NSString *endFieldText = endField.text;

	NSMutableDictionary *tripRequest = [NSMutableDictionary dictionary];

	// setup the trip request with either coordinates or addresses
	if ([startFieldText isEqualToString:@"Current Location"]) {

		CLLocation *startLocation = locationManager.location;

		[tripRequest setValue:startLocation forKey:@"start"];
	} else [tripRequest setValue:startFieldText forKey:@"start"];

	if ([endFieldText isEqualToString:@"Current Location"]) {

		CLLocation *endLocation = locationManager.location;

		[tripRequest setValue:endLocation forKey:@"end"];
	} else [tripRequest setValue:endFieldText forKey:@"end"];
	// show trip fetching activity indicator
	[tripFetchSpinner startAnimating];

	// request trips
	[tripFetcher performSelectorInBackground:@selector(fetchTripsForRequest:) withObject:tripRequest];

	[locationManager stopUpdatingLocation];

}

// When the cancel button is tapped, make it disabled
// Check if there's enough text in the fields to keep the "Route" button enabled
- (void) cancelTrip {

	[startField resignFirstResponder];
	[endField resignFirstResponder];

	self.navigationItem.leftBarButtonItem.enabled = NO;

	[self setRouteButtonStatus];

}

// Convenience method used a few places to check whether the "Route" button should be enabled based on the text field contents
- (void) setRouteButtonStatus {

	if ( ([startField.text length] > 1)&&([endField.text length] > 1) ) self.navigationItem.rightBarButtonItem.enabled = YES;
	else self.navigationItem.rightBarButtonItem.enabled = NO;
}

// Switches the contents of the start and end fields
- (IBAction) switchFieldsContents {

	NSString *storedStartField = [[NSString alloc] initWithString:startField.text];
	startField.text = endField.text;
	endField.text = storedStartField;


	// switch which text field is first responder
	if ([startField isFirstResponder]) {
		[startField resignFirstResponder];
		[endField becomeFirstResponder];
	} else {
		[endField resignFirstResponder];
		[startField becomeFirstResponder];
	}
}

#pragma mark -
#pragma mark Memory

- (void) viewDidUnload {

	[locationManager stopUpdatingLocation];

	self.startField = nil;
	self.endField = nil;
	self.changeTimeButton = nil;
	self.switchFieldsButton = nil;
	self.mapView = nil;
	self.inputView = nil;
}

- (void) dealloc {

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];


}

@end
