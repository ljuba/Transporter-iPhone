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

    // There should be at least 1 "show" directions. Find them and set them to first and last Directions
    Direction *firstDirection, *secondDirection;
    for (Direction *d in self.route.directions) {
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
    Stop *lastStop = [tagToStopLookup objectForKey:[firstDirection.stopOrder objectAtIndex:[firstDirection.stopOrder count]-1]];
    StopAnnotation *stopAnnotation = [[StopAnnotation alloc] initWithStop:lastStop];
    stopAnnotation.direction = firstDirection;
    
    [self.mapView addAnnotation:stopAnnotation];

    
    
    if (secondDirection) {
    
        Stop *firstStop = [tagToStopLookup objectForKey:[firstDirection.stopOrder objectAtIndex:0]];
        stopAnnotation = [[StopAnnotation alloc] initWithStop:firstStop];
        stopAnnotation.direction = secondDirection;
        
        [self.mapView addAnnotation:stopAnnotation];
    
    }

    // Create an MKPolyline with the points
    MKPolyline *line = [MKPolyline polylineWithCoordinates:pointsArray count:numberOfStops];
    [self.mapView addOverlay:line];
    
    
    
    // Zoom the map to include all of the MKPolyline
   

//    MKMapPoint firstStopMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake([firstStop.lat doubleValue], [firstStop.lon doubleValue]));
//    MKMapPoint lastStopMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake([lastStop.lat doubleValue], [lastStop.lon doubleValue]));
//    
//    NSLog(@"%f", firstStopMapPoint.x);
//    
    
    
    
//    MKMapRect newMapRect;
//    
//    self.mapView.visibleMapRect = newMapRect;
    


}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [self setMapViewRegion];

}

- (void)setMapViewRegion {
    
    for (id annotation in mapView.overlays) {
        
        if ([annotation isKindOfClass:[MKPolyline class]]) {
            
            MKPolyline *line = (MKPolyline *)annotation;
            
            [mapView setVisibleMapRect:line.boundingMapRect];
            
        }
        
    }
    
    // Zoom out a bit to show all of the annotationViews.
    // There may be a better way to calculate where on the map the annotationViews show so
    // that we can zoom apropriately. For now, this should do.
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        region.center = self.mapView.region.center;
        span.latitudeDelta = self.mapView.region.span.latitudeDelta * 2.0;
        span.longitudeDelta = self.mapView.region.span.longitudeDelta * 2.0;
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
        view.strokeColor = [UIColor blueColor];     //LJUBA TODO CHANGE COLOR OF LINE
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
        annotationView.mapFrame = self.mapView.frame;

//        NSString *routeTag = stop.direction.route.tag;
		NSString *agencyShortTitle = stop.direction.route.agency.shortTitle;
        if ([agencyShortTitle isEqualToString:@"sf-muni"]) {
            annotationView.centerOffset = CGPointMake(2, -45);
        }
        else if ([agencyShortTitle isEqualToString:@"actransit"]) {
            annotationView.centerOffset = CGPointMake(-8, -45);
        }
        
        
//        if ( ([routeTag isEqualToString:@"22"]||
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
		
        //PASS IN X,Y RELATIVE TO MAPVIEW
        //[annotationView setPoint:CGPointMake(x, y)];
        
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
