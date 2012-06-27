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

@implementation DirectionsVC

@synthesize mapView;

@synthesize route, directions;

- (void) viewDidLoad {
	[super viewDidLoad];

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
    Direction *direction;
    
    for (Direction *d in selectedRoute.directions) {
        if ([d.show intValue] == 1) {
            direction = d;
            break;
        }
    }
    
    NSAssert(direction, @"Doh");
    
    NSUInteger numberOfStops = [direction.stops count];
    CLLocationCoordinate2D pointsArray[numberOfStops];
    
    // Fetch all of the stops in one shot so we don't query CD often
    NSArray *stops = [DataHelper stopsWithTags:direction.stopOrder inAgency:self.route.agency];
    
    NSMutableDictionary *tagToStopLookup = [NSMutableDictionary dictionaryWithCapacity:[stops count]];
    for (Stop *stop in stops) {
        [tagToStopLookup setObject:stop forKey:stop.tag];
    }
    // THIS IS WHERE I USE STOP ORDER TO DETERMINE WHERE TO PUT THE MKPOLYLINE
    
    MKMapRect mapRect = MKMapRectNull;
    // Given the sorted list of stops, fetch each one and put it in the points array
    int i = 0;
    for (NSString *stopTag in direction.stopOrder) {
        Stop *stop = [tagToStopLookup objectForKey:stopTag];        
        CLLocationCoordinate2D pt = CLLocationCoordinate2DMake([stop.lat doubleValue], [stop.lon doubleValue]);
        pointsArray[i++] = pt;
        
        MKMapPoint mapPoint = MKMapPointForCoordinate(pt);
        MKMapRect rectWithThisPoint = MKMapRectMake(mapPoint.x, mapPoint.y, 0.01f, 0.01f);
        mapRect = MKMapRectUnion(mapRect, rectWithThisPoint);  
    }
    
    // Add annotations for the first and last stop    
    Stop *firstStop = [tagToStopLookup objectForKey:[direction.stopOrder objectAtIndex:0]];
    StopAnnotation *stopAnnotation = [[StopAnnotation alloc] initWithStop:firstStop];
    [self.mapView addAnnotation:stopAnnotation];
    
    Stop *lastStop = [tagToStopLookup objectForKey:[direction.stopOrder objectAtIndex:[direction.stopOrder count]-1]];
    stopAnnotation = [[StopAnnotation alloc] initWithStop:lastStop];
    stopAnnotation.direction = direction;
    [self.mapView addAnnotation:stopAnnotation];
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:pointsArray count:numberOfStops];

    [self.mapView addOverlay:line];    
    self.mapView.visibleMapRect = line.boundingMapRect;

//	// create directionAnnotation for each direction whose show = true
//	for (Direction *direction in shownDirections) {
//
//		NSString *directionXPath = [NSString stringWithFormat:@"direction[@tag='%@']", direction.tag];
//
//		CXMLElement *directionElement = [[routeNode nodesForXPath:directionXPath error:nil] objectAtIndex:0];
//
//		// map coordinates for the direction's destination
//		int x = [[[directionElement attributeForName:@"x"] stringValue] intValue];
//		int y = [[[directionElement attributeForName:@"y"] stringValue] intValue];
//
//		// NSLog(@"%@ (%i,%i)", direction.name, x,y); /* DEBUG LOG */
//
//		NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"DirectionAnnotationView" owner:self options:nil];
//		DirectionAnnotationView *pin = [nibs objectAtIndex:0];
//
//		//pin.mapFrame = self.routeMap.frame;
//		[pin setDirection:direction];
//
//		// special cases for loop routes
//		NSString *routeTag = direction.route.tag;
//		NSString *agencyShortTitle = direction.route.agency.shortTitle;
//		int pinIndex = [shownDirections indexOfObject:direction];
//		int verticalOffset = 0;
//
//		if ( ([routeTag isEqualToString:@"22"]||
//		      [routeTag isEqualToString:@"25"]||[routeTag isEqualToString:@"49"]||
//		      [routeTag isEqualToString:@"89"]||[routeTag isEqualToString:@"93"]||
//		      [routeTag isEqualToString:@"98"]||[routeTag isEqualToString:@"242"]||
//		      [routeTag isEqualToString:@"251"]||[routeTag isEqualToString:@"275"]||
//		      [routeTag isEqualToString:@"350"]||[routeTag isEqualToString:@"376"])&&[agencyShortTitle isEqualToString:@"actransit"] ) {
//			if (pinIndex == 0) {
//
//				pin.pinView.hidden = YES;
//				verticalOffset = -50;
//				pin.subtitle.text = @"";
//
//				pin.title.frame = CGRectMake(pin.title.frame.origin.x, pin.title.frame.origin.y + 6, pin.title.frame.size.width, pin.title.frame.size.height);
//
//			} else {
//				pin.subtitle.text = @"";
//
//				pin.title.frame = CGRectMake(pin.title.frame.origin.x, pin.title.frame.origin.y + 6, pin.title.frame.size.width, pin.title.frame.size.height);
//
//			}
//		}
//		[pin setPoint:CGPointMake(x, y + verticalOffset)];
//
//	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	// setup notification to listen to notifications from directionAnnotationsView
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(directionSelected:) name:@"directionTapped" object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleLocationUpdating:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	// UIView will be "transparent" for touch events if we return NO
	return(NO);

}


// Load the stopsTVC once a direction is selected
- (void) directionSelected:(NSNotification *)note {

	Direction *tappedDirection = note.object;

	StopsTVC *stopsTableViewController = [[StopsTVC alloc] init];
	stopsTableViewController.direction = tappedDirection;

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
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:nil];
        annotationView.canShowCallout = YES;
        
        UIImage *callout = [UIImage imageNamed:@"direction-callout.png"];
        
        CGRect resizeRect;
        
        resizeRect.size = callout.size;
        CGSize maxSize = CGRectInset(self.view.bounds,50, 50).size;
        maxSize.height -= self.navigationController.navigationBar.frame.size.height + 50;
        if (resizeRect.size.width > maxSize.width)
            resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
        if (resizeRect.size.height > maxSize.height)
            resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
        
        resizeRect.origin = (CGPoint){0.0f, 0.0f};
        UIGraphicsBeginImageContext(resizeRect.size);
        [callout drawInRect:resizeRect];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        annotationView.image = resizedImage;
        annotationView.opaque = NO;
        annotationView.canShowCallout = NO;
        
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
