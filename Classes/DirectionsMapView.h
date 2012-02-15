//
//  DirectionsVC.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Direction.h"
#import "Route.h"
#import "DirectionAnnotationView.h"
#import <CoreLocation/CoreLocation.h>
#import "StopsTVC.h"

@interface DirectionsMapView : UIViewController <CLLocationManagerDelegate> {

	NSArray *directions;
	Route *route;
	
	int zoomLevel;								//used to position the user location on the static map
	int yCropPixels;							//used to position the user location on the static map
	CLLocationCoordinate2D centerCoordinate;	//used to position the user location on the static map
	
	UIImageView *routeMap;
	CLLocationManager *locationManager;
}

@property (nonatomic, retain) NSArray *directions;
@property (nonatomic, retain) Route *route;

@property (nonatomic, retain) IBOutlet UIImageView *routeMap;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property CLLocationCoordinate2D centerCoordinate;
@property int zoomLevel;
@property int yCropPixels;

- (void)directionSelected:(NSNotification *)note;
- (void)toggleLocationUpdating:(NSNotification *)note;

@end
