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
@property (nonatomic, strong) Direction *direction;
@property (nonatomic, strong) Stop *destinationStop;
@property (nonatomic, strong) Stop *stop;

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSMutableArray *colors;

@property (nonatomic, strong) NSString *platform;

- (id) initWithDestinationStop:(Stop *)_destinationStop forStop:(Stop *)_stop;

@end
