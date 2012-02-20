//
// Destination.h
// kronos
//
// Created by Ljuba Miljkovic on 4/17/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//
// Used in StopDetialsVC for to store information about BART rows

#import "Direction.h"
#import "Stop.h"
#import <Foundation/Foundation.h>

@interface Destination : NSObject {

	Stop *destinationStop;
	Stop *stop;
	NSArray *routes;                // routes that pass through this destinationStop
	NSMutableArray *colors;         // ordered colors of the routes that pass through the stop to the destinationStop
	NSString *platform;

	Direction *direction;

}
@property (nonatomic, retain) Direction *direction;
@property (nonatomic, retain) Stop *destinationStop;
@property (nonatomic, retain) Stop *stop;

@property (nonatomic, retain) NSArray *routes;
@property (nonatomic, retain) NSMutableArray *colors;

@property (nonatomic, retain) NSString *platform;

- (id) initWithDestinationStop:(Stop *)_destinationStop forStop:(Stop *)_stop;

@end
