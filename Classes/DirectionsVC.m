//
// DirectionsVC.m
// kronos
//
// Created by Ljuba Miljkovic on 3/15/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "DirectionsVC.h"
#import "TouchXML.h"
#import "StopAnnotation.h"

#import "NewDirectionAnnotationView.h"

@implementation DirectionsVC

@synthesize mapView;

@synthesize route, directions;


#define showMapFirstThenLoadData

#ifdef showMapFirstThenLoadData
- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
#else
- (void) viewDidLoad {
    [super viewDidLoad];
#endif

	// find the directions whose show=true
	NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"show == %@", [NSNumber numberWithBool:YES]];
	self.directions = [[self.route.directions allObjects] filteredArrayUsingPredicate:filterPredicate];

	if ([self.route.vehicle isEqual:@"cablecar"]) {

		NSString *routeTitle;

		if ([self.route.title isEqualToString:@"PowllMason Cable"]) routeTitle = @"Powell Mason Cable Car";
		else if ([self.route.title isEqualToString:@"PowellHyde Cable"]) routeTitle = @"Powell Hyde Cable Car";
		else if ([self.route.title isEqualToString:@"Calif. Cable Car"]) routeTitle = @"California Cable Car";
		else routeTitle = self.route.title;
		self.title = routeTitle;
	} else if ([self.route.vehicle isEqual:@"streetcar"]) self.title = [NSString stringWithFormat:@"%@ Street Car", self.route.tag];
	else if ([self.route.vehicle isEqual:@"metro"]) self.title = [NSString stringWithFormat:@"%@ Metro", self.route.tag];
	else if ([self.route.vehicle isEqual:@"bus"]) self.title = [NSString stringWithFormat:@"%@ Bus", self.route.tag];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Directions" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;

//	// find directions whose show=true
	NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];                // sort the directions so that when the order matters, they're always in the same order
	[self.directions sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];

	// load the file that contains the (x,y) coordinate points for the pins on the route map
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"map_overlay_coordinates" ofType:@"xml"];
	NSData *coordinateData = [NSData dataWithContentsOfFile:filePath];
//
	CXMLDocument *coordinateParser = [[CXMLDocument alloc] initWithData:coordinateData options:0 error:nil];
//
	NSString *routeXPath = [NSString stringWithFormat:@"//body/agency[@shortTitle='%@']/route[@tag='%@']", self.route.agency.shortTitle, self.route.tag];
    // the xml element that contains both directions we care about
	CXMLElement *routeNode = [[coordinateParser nodesForXPath:routeXPath error:nil] objectAtIndex:0];

	NSString *tag = [[routeNode attributeForName:@"tag"] stringValue];
    Route *selectedRoute = [DataHelper routeWithTag:tag inAgency:self.route.agency];

    // There should be at least 2 "show" directions. Find them and set them to first and last Directions
    Direction *firstDirection, *secondDirection;
    for (Direction *d in selectedRoute.directions) {
        if ([d.show intValue] == 1) {
            // If we are to show this direction, set it to the firstDirection
            if (!firstDirection) {
                firstDirection = d;
            }
            else {
                // If we already have the first direction, set the second
                secondDirection = d;
                break;
            }
        }
    }

    NSAssert(firstDirection && secondDirection, @"We should have a direction at this point. The %@ line must not have a direction with show == True", tag);
    
    NSUInteger numberOfStops = [firstDirection.stops count];
    CLLocationCoordinate2D pointsArray[numberOfStops];
    
    // Fetch all of the stops in one shot so we don't query CD often
    NSArray *stops = [DataHelper stopsWithTags:firstDirection.stopOrder inAgency:self.route.agency];
    
    NSMutableDictionary *tagToStopLookup = [NSMutableDictionary dictionaryWithCapacity:[stops count]];
    for (Stop *stop in stops) {
        [tagToStopLookup setObject:stop forKey:stop.tag];
    }
        
    // Given the sorted list of stops, fetch each one and put it in the points array
    int i = 0;
    for (NSString *stopTag in firstDirection.stopOrder) {
        Stop *stop = [tagToStopLookup objectForKey:stopTag];        
        CLLocationCoordinate2D pt = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lon doubleValue]);
        pointsArray[i++] = pt;
    }

    // Add annotations for the first and last stop, this are buttons the user can press    
    Stop *firstStop = [tagToStopLookup objectForKey:[firstDirection.stopOrder objectAtIndex:0]];
    StopAnnotation *stopAnnotation = [[StopAnnotation alloc] initWithStop:firstStop];
    stopAnnotation.direction = secondDirection;
    
    [self.mapView addAnnotation:stopAnnotation];
    
    Stop *lastStop = [tagToStopLookup objectForKey:[firstDirection.stopOrder objectAtIndex:[firstDirection.stopOrder count]-1]];
    stopAnnotation = [[StopAnnotation alloc] initWithStop:lastStop];
    stopAnnotation.direction = firstDirection;
    
    [self.mapView addAnnotation:stopAnnotation];
    
    // Create an MKPolyline with the points
    MKPolyline *line = [MKPolyline polylineWithCoordinates:pointsArray count:numberOfStops];
    [self.mapView addOverlay:line];    
    
    // Zoom the map to include all of the MKPolyline
    self.mapView.visibleMapRect = line.boundingMapRect;

    // Zoom out a bit to show all of the annotationViews.
    // There may be a better way to calculate where on the map the annotationViews show so 
    // that we can zoom apropriately. For now, this should do.
    MKCoordinateRegion region;
    MKCoordinateSpan span;  
    region.center = self.mapView.region.center;
    span.latitudeDelta = self.mapView.region.span.latitudeDelta * 2;
    span.longitudeDelta = self.mapView.region.span.longitudeDelta * 2;
    region.span = span;
    [self.mapView setRegion:region animated:TRUE];
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	// UIView will be "transparent" for touch events if we return NO
	return(NO);
}

// Load the stopsTVC once a direction is selected
- (void)directionSelected:(Direction *)direction {
    StopsTVC *stopsTableViewController = [[StopsTVC alloc] init];
	stopsTableViewController.direction = direction;
	[self.navigationController pushViewController:stopsTableViewController animated:YES];
}

#pragma mark - MKMapViewDelegate
- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:overlay];
        view.strokeColor = [UIColor blueColor];
        return view;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[StopAnnotation class]])   // for City of San Francisco
    {
        StopAnnotation *stop = (StopAnnotation *)annotation;
        NewDirectionAnnotationView *annotationView = [[NewDirectionAnnotationView alloc] initWithAnnotation:annotation
                                                                                            reuseIdentifier:nil];       
        // Set the properties of the StopAnnotation
        annotationView.annotation = stop;        
        annotationView.direction = stop.direction;
        annotationView.delegate = self;
        return annotationView;
    }
    return nil;
}

#pragma mark -
#pragma mark Memory

- (void) viewDidUnload {
    [self setMapView:nil];
	// Release any retained subviews of the main view.
}





@end
