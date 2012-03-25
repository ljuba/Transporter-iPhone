//
// NearMeVC.m
// kronos
//
// Created by Ljuba Miljkovic on 3/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "NearMeVC.h"
#import "StopAnnotation.h"
#import "kronosAppDelegate.h"

#import "Agency.h"
#import "Direction.h"
#import "Route.h"
#import "Stop.h"

#define kMaxSpan 0.002
#define kRegionMargin 1.0

@implementation NearMeVC

@synthesize mapView, locationManager, previousStopAnnotations, autoRecenterMap;

#pragma mark -

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[super viewDidLoad];

	// settings
	NSString *backTitle = [NSString stringWithString:@"Map"];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	self.previousStopAnnotations = nil;           // in case regionWillChangeAnimated is never called, set this to nil so it can be "released"

	// setup core location
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[self.locationManager startUpdatingLocation];

	MKCoordinateRegion region;
	CLLocationCoordinate2D center;

	// load last map region and center from nsdefaults
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	center.latitude = [userDefaults doubleForKey:@"nearMeMapCenterLatitutde"];
	center.longitude = [userDefaults doubleForKey:@"nearMeMapCenterLongitude"];
	region.span.latitudeDelta = [userDefaults doubleForKey:@"nearMeMapRegionLatitudeDelta"];
	region.span.longitudeDelta = [userDefaults doubleForKey:@"nearMeMapRegionLongitudeDelta"];

	// if there's no saved location, set the map to the bay area...
	if ( (center.latitude == 0)||(region.span.latitudeDelta == 0) ) {
		center.latitude = 37.759859;
		center.longitude = -122.226334;

		region.span.latitudeDelta = 1;
		region.span.longitudeDelta = 1;

	}
	region.center = center;

	[self.mapView setRegion:region animated:NO];
	[self.mapView regionThatFits:region];
}

// perform once the view loads
- (void) viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];
	autoRecenterMap = YES;

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationDidBecomeActiveNotification object:nil];

}

// stop the automatic fetching of predictions once the view is gone
- (void) viewWillDisappear:(BOOL)animated {

	[super viewWillDisappear:animated];
	[self.locationManager stopUpdatingLocation];

	// SAVE MAP CENTER AND REGION
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:self.mapView.region.center.latitude forKey:@"nearMeMapCenterLatitutde"];
	[userDefaults setDouble:self.mapView.region.center.longitude forKey:@"nearMeMapCenterLongitude"];
	[userDefaults setDouble:self.mapView.region.span.latitudeDelta forKey:@"nearMeMapRegionLatitudeDelta"];
	[userDefaults setDouble:self.mapView.region.span.longitudeDelta forKey:@"nearMeMapRegionLongitudeDelta"];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];

}

// turns off location updating
- (void) toggleLocationUpdating:(NSNotification *)note {

	if ([note.name isEqual:UIApplicationWillResignActiveNotification]) {

		[self.locationManager stopUpdatingLocation];
	} else if ([note.name isEqual:UIApplicationDidBecomeActiveNotification]) {

		[self.locationManager startUpdatingLocation];
	}
}

#pragma mark -
#pragma mark Annotations

- (void) mapView:(MKMapView *)_mapView regionWillChangeAnimated:(BOOL)animated {

	self.previousStopAnnotations = [NSMutableArray arrayWithArray:_mapView.annotations];

	// exclude all non-stopAnnotations
	for (int i = 0; i < [self.previousStopAnnotations count]; i++)

		if (![[self.previousStopAnnotations objectAtIndex:i] isKindOfClass:[StopAnnotation class]]) [self.previousStopAnnotations removeObjectAtIndex:i];
}

// adds and removes stop annotations when the map changes regions
- (void) mapView:(MKMapView *)_mapView regionDidChangeAnimated:(BOOL)animated {

	// don't at stop annotaitons if the mapview region is too large
	if (_mapView.region.span.latitudeDelta * 111000 > 1000) return;
	// array of the annotations currently in the map view.
	// annotationsToDelete is pre-made with all of the annotations so they can be filtered out later.
	NSMutableArray *annotationsToDelete = [NSMutableArray arrayWithArray:self.previousStopAnnotations];

	// get an array of annotations for the stops that should be displayed in the map
	// annotationsToAdd is pre-made with all of the annotations so they can be filtered out later.
	NSMutableArray *visibleAnnotations = [self getStopAnnotationsForRegion:_mapView.region];
	NSMutableArray *annotationsToAdd = [NSMutableArray arrayWithArray:visibleAnnotations];

	// find the annotations that are no longer visible in annotationsToDelete
	// annotationsToDelete is the same as previousAnnotations at this point
	[annotationsToDelete removeObjectsInArray:visibleAnnotations];


	// remove the no-longer-visible annotations
	[_mapView removeAnnotations:annotationsToDelete];

	// find the annotations that are newly visible in annotationsToAdd
	// annotationsToAdde is the same as visibleAnnotations at this point
	[annotationsToAdd removeObjectsInArray:self.previousStopAnnotations];


	// add the newly visible annotations
	[_mapView addAnnotations:annotationsToAdd];

}

// returns an array of stop annations found in the supplied map region
- (NSMutableArray *) getStopAnnotationsForRegion:(MKCoordinateRegion)region {

	// get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

	// Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];

	// how much wider than the map region do you want stops to appear for
	float factor = 2;

	// determine the min and max latitude
	NSNumber *latMin = [NSNumber numberWithDouble:region.center.latitude - (region.span.latitudeDelta / 2) * factor];
	NSNumber *latMax = [NSNumber numberWithDouble:region.center.latitude + (region.span.latitudeDelta / 2) * factor];

	// determine the min and max longitude
	NSNumber *lonMin = [NSNumber numberWithDouble:region.center.longitude - (region.span.longitudeDelta / 2) * factor];
	NSNumber *lonMax = [NSNumber numberWithDouble:region.center.longitude + (region.span.longitudeDelta / 2) * factor];

	// find stops inside the map region
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lat > %@ && lat < %@ && lon > %@ && lon < %@", latMin, latMax, lonMin, lonMax];
	[request setPredicate:predicate];

	// Receive the results
	NSError *error;
	NSMutableArray *stopsInRegion = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];


	// create array of stopAnnotations for the stops

	NSMutableArray *stopAnnotations = [[NSMutableArray alloc] init];

	for (Stop *stop in stopsInRegion) {

		StopAnnotation *stopAnnotation = [[StopAnnotation alloc] initWithStop:stop];

		[stopAnnotations addObject:stopAnnotation];


	}

	return(stopAnnotations);

}

// called every time an annotation comes into view of the map
- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {

	static NSString *stopIdentifier = @"Stop Identifier";

	if ([annotation isKindOfClass:[StopAnnotation class]]) {

		// dequeue existing annotationView. if it's nill, create a new one from the passed-in annotation...
		MKAnnotationView *annotationView = (MKAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:stopIdentifier];

		if (annotationView == nil) {
			annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stopIdentifier];
			annotationView.canShowCallout = YES;

			UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[stopButton addTarget:self action:@selector(selectStop) forControlEvents:UIControlEventTouchUpInside];

			annotationView.rightCalloutAccessoryView = stopButton;

		} else
			// otherwise, use the dequeued annotationView for the passed-in annotation
			annotationView.annotation = annotation;
		Stop *stop = [(StopAnnotation *) annotation stop];
		Agency *agency = [DataHelper agencyFromStop:stop];

		if ([agency.shortTitle isEqual:@"actransit"]) {
			annotationView.image = [UIImage imageNamed:@"pin-ac.png"];
			annotationView.centerOffset = CGPointMake(7, -14);
			annotationView.calloutOffset = CGPointMake(-12, -2);
		} else if ([agency.shortTitle isEqual:@"sf-muni"]) {
			annotationView.image = [UIImage imageNamed:@"pin-muni.png"];
			annotationView.centerOffset = CGPointMake(13, -17);
			annotationView.calloutOffset = CGPointMake(-9, -2);
		} else {
			annotationView.image = [UIImage imageNamed:@"pin-bart.png"];
			annotationView.centerOffset = CGPointMake(9, 1);
			annotationView.calloutOffset = CGPointMake(-8, -2);
		}
		return(annotationView);
	}
	return(nil);
}

// prevents the user location annotation view from being selected
- (void)mapView:(MKMapView *)_mapView didAddAnnotationViews:(NSArray *)views
{
	for (MKAnnotationView *view in views)
		if ([view.annotation isKindOfClass:[MKUserLocation class]]) view.canShowCallout = NO;
}

// load the stopDetailVC when the right accessory button is tapped
- (void)selectStop {

	StopAnnotation *stopAnnotation;

	// check b/c of differences between iPhone OS 3.0 and 3.1.2
	if ([[self.mapView.selectedAnnotations objectAtIndex:0] isMemberOfClass:[StopAnnotation class]]) stopAnnotation = [self.mapView.selectedAnnotations objectAtIndex:0];

	else stopAnnotation = [[self.mapView.selectedAnnotations objectAtIndex:0] annotation];
	NSString *agencyShortTitle = [[DataHelper agencyFromStop:stopAnnotation.stop] shortTitle];

	if ([agencyShortTitle isEqualToString:@"bart"]) {

		BartStopDetails *bartStopDetails = [[BartStopDetails alloc] init];
		bartStopDetails.stop = stopAnnotation.stop;

		[self.navigationController pushViewController:bartStopDetails animated:YES];

	} else {
		NextBusStopDetails *nextBusStopDetails = [[NextBusStopDetails alloc] init];
		nextBusStopDetails.stop = stopAnnotation.stop;

		[self.navigationController pushViewController:nextBusStopDetails animated:YES];
	}
}

#pragma mark -
#pragma mark Location

// notify the class when there is a new location update
- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {


	// don't update location if location fix accuracy is invalid (negative) or if the timestamp is more then 120 seconds old
	if ( (newLocation.horizontalAccuracy < 0)||([newLocation.timestamp timeIntervalSinceNow] < -120) ) return;

	if (autoRecenterMap) {

		// coordinate region to set the map to when the location changes
		MKCoordinateRegion region;

		// don't make the map region any smaller than this (twice the accuracy radius (converted to degrees) with an extra margin of 20%), no matter the accuracy of the reading
		if (2 * 1.2 * newLocation.horizontalAccuracy / 111000 < kMaxSpan) {
			region.span.longitudeDelta = kMaxSpan;
			region.span.latitudeDelta = kMaxSpan;
		} else
			// twice the accuracy radius (converted to degrees) with an extra margin of 10%
			region.span.longitudeDelta = region.span.latitudeDelta = 2 * kRegionMargin * newLocation.horizontalAccuracy / 111000;
		region.center = newLocation.coordinate;

		[self.mapView setRegion:region animated:YES];
		[self.mapView regionThatFits:region];

		// if the fix is really good, don't recenter the map anymore and stop updating location, unless the user taps on the find-me button
		if (newLocation.horizontalAccuracy < 200) {
			autoRecenterMap = NO;
			[manager stopUpdatingLocation];
		}
	} else return;
}

// recenter the map to the current location at the current level of zoom
- (IBAction) recenterMap {

	[self.locationManager startUpdatingLocation];
	autoRecenterMap = YES;

}

#pragma mark -
#pragma mark Memory

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload {
	self.mapView = nil;
}


@end
