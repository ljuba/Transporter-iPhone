//
// StopAnnotation.m
// kronos
//
// Created by Ljuba Miljkovic on 3/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "StopAnnotation.h"
#import <MapKit/MapKit.h>

@implementation StopAnnotation

@synthesize stop, coordinate, agency, direction;

- (id) initWithStop:(Stop *)_stop {

	self = [super init];

	// set stopAnnotation coordinates
	coordinate.latitude = [_stop.lat doubleValue];
	coordinate.longitude = [_stop.lon doubleValue];

	self.agency = [DataHelper agencyFromStop:_stop];

	self.stop = _stop;

	return(self);

}

// returns the title of annotation as the stop name
- (NSString *) title {

	if ([self.agency.shortTitle isEqual:@"bart"]) return([NSString stringWithFormat:@"%@ BART", self.stop.title]);
	return(self.stop.title);

}

// returns the routes that pass through this stop
- (NSString *) subtitle {

	if ([self.agency.shortTitle isEqual:@"bart"]) return(nil);
	NSArray *routes = [DataHelper uniqueRoutesForStop:self.stop];

	NSMutableString *linesString = [NSMutableString string];
    
	for (Route *route in routes) [linesString appendFormat:@"%@ ", route.tag];
	return(linesString);

}

// needed to overwrite the equality method to make sure comparisons in NearMeVC "regionDidChangeAnimated" work properly
- (BOOL) isEqual:(id)otherObject;
{
	if ([otherObject isKindOfClass:[StopAnnotation class]]) {

		StopAnnotation *otherStopAnnotation = (StopAnnotation *)otherObject;

		if ([self.stop.tag isEqual:otherStopAnnotation.stop.tag]&&[self.stop.lat isEqual:otherStopAnnotation.stop.lat]) return(YES);
		else return(NO);
	}
	return(NO);
}

- (NSUInteger) hash;
{
	return([self.stop.tag hash]^[ stop.lat hash]^[ stop.lon hash]);
}

#pragma mark -


@end
