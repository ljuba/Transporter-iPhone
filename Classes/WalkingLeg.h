//
// WalkingLeg.h
// kronos
//
// Created by Ljuba Miljkovic on 4/21/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

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

@property (nonatomic, strong) NSDate *date;

@property (nonatomic) NSString *destinationTitle;

@end
