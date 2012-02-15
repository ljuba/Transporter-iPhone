//
//  TripOverviewMapDelegate.m
//  kronos
//
//  Created by Ljuba Miljkovic on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripOverviewMapDelegate.h"
#import "StopAnnotation.h"
#import "DataHelper.h"

@implementation TripOverviewMapDelegate

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {

	static NSString *stopIdentifier = @"Stop Identifier"; 
	
	if ([annotation isKindOfClass:[StopAnnotation class]]) {
		
		//dequeue existing annotationView. if it's nill, create a new one from the passed-in annotation...
		MKAnnotationView *annotationView = (MKAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:stopIdentifier];
		if (annotationView == nil) { 
			annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stopIdentifier] autorelease];
			annotationView.canShowCallout = YES;
			
		} 
		else {
			//otherwise, use the dequeued annotationView for the passed-in annotation
			annotationView.annotation = annotation;
		}
		
		Stop *stop = [(StopAnnotation *)annotation stop];
		Agency *agency = [DataHelper agencyFromStop:stop];
		
		if ([agency.shortTitle isEqual:@"actransit"]){
			annotationView.image = [UIImage imageNamed:@"pin-ac.png"];
			annotationView.centerOffset = CGPointMake(7, -14);
			annotationView.calloutOffset = CGPointMake(-12, -2);
		}
		else if ([agency.shortTitle isEqual:@"sf-muni"]) {
			annotationView.image = [UIImage imageNamed:@"pin-muni.png"];
			annotationView.centerOffset = CGPointMake(13, -17);
			annotationView.calloutOffset = CGPointMake(-9, -2);
		}
		else {
			annotationView.image = [UIImage imageNamed:@"pin-bart.png"];
			annotationView.centerOffset = CGPointMake(9, 1);
			annotationView.calloutOffset = CGPointMake(-8, -2);
		}
		
		return annotationView;
	} 
	
	return nil;

	
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

	//NSLog(@"%f", mapView.region.span.latitudeDelta); /* DEBUG LOG */	
	//NSLog(@"%f", mapView.region.span.longitudeDelta); /* DEBUG LOG */	
	
}



@end
