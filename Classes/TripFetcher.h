//
// TripFetcher.h
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripFetcher : NSObject {}

- (void) fetchTripsForRequest:(NSMutableDictionary *)tripRequest;

@end
