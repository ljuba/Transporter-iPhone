//
// StopAnnotation.h
// kronos
//
// Created by Ljuba Miljkovic on 3/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Agency.h"
#import "Direction.h"
#import "Route.h"
#import "Stop.h"

@interface StopAnnotation : NSObject <MKAnnotation> {

	Stop *stop;
	Agency *agency;

	CLLocationCoordinate2D coordinate;

}

@property (nonatomic, strong) Stop *stop;
@property (nonatomic, strong) Agency *agency;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (id) initWithStop:(Stop *)_stop;

@end
