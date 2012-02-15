//
//  WalkingLeg.h
//  kronos
//
//  Created by Ljuba Miljkovic on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WalkingLeg : NSObject {

	CLLocationCoordinate2D startLocationCoordinate;
	CLLocationCoordinate2D endLocationCoordinate;
	
	NSTimeInterval duration;
	
	NSString *destinationTitle;
	
	NSDate *date;
	
	
}

@property CLLocationCoordinate2D startLocationCoordinate;
@property CLLocationCoordinate2D endLocationCoordinate;

@property NSTimeInterval duration;

@property (nonatomic, retain) NSDate *date;

@property (nonatomic, retain) NSString *destinationTitle;


@end
