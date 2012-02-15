//
//  StopAnnotation.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "Stop.h"
#import "Direction.h"
#import "Route.h"
#import "Agency.h"


@interface StopAnnotation : NSObject <MKAnnotation> {

	Stop *stop;
	Agency *agency;
	
	CLLocationCoordinate2D coordinate;
	
}

@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) Agency *agency;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

-(id)initWithStop:(Stop *)_stop;

@end
