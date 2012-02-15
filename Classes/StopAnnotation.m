//
//  StopAnnotation.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopAnnotation.h"
#import <MapKit/MapKit.h>
#import "DataHelper.h"

@implementation StopAnnotation

@synthesize stop, coordinate, agency;

-(id)initWithStop:(Stop *)_stop {
	
	self = [super init];
	
	//set stopAnnotation coordinates
	coordinate.latitude = [_stop.lat doubleValue];
	coordinate.longitude = [_stop.lon doubleValue];
	
	
	self.agency = [DataHelper agencyFromStop:_stop];
	
	self.stop = _stop;
	
	return self;
	
	
}

//returns the title of annotation as the stop name
- (NSString *)title {

	if ([agency.shortTitle isEqual:@"bart"]) {
		
		return [NSString stringWithFormat:@"%@ BART", stop.title];
		
	}
	
	return stop.title;
	
}

//returns the routes that pass through this stop
- (NSString *)subtitle {
	
	//debug option
	//return stop.tag;
	
	if ([agency.shortTitle isEqual:@"bart"]) {
		
		return nil;		
	}
	
	
	NSArray *routes = [DataHelper uniqueRoutesForStop:stop];
	
	NSMutableString *linesString = [NSMutableString string];

	//[linesString appendFormat:@"%@: ", stop.tag];
	
	for (Route *route in routes) {
		[linesString appendFormat:@"%@ ", route.tag];
	}
	
	return linesString;
	
	
}

//needed to overwrite the equality method to make sure comparisons in NearMeVC "regionDidChangeAnimated" work properly
- (BOOL)isEqual:(id)otherObject;
{
	if ([otherObject isKindOfClass:[StopAnnotation class]]) {
		
		StopAnnotation *otherStopAnnotation = (StopAnnotation *)otherObject;
		
		if ([stop.tag isEqual:otherStopAnnotation.stop.tag] && [stop.lat isEqual:otherStopAnnotation.stop.lat]){
			return YES;
		}
		else {
			return NO;
		}
	}
	
	return NO;
}

- (NSUInteger) hash;
{
	return [stop.tag hash] ^ [stop.lat hash] ^ [stop.lon hash];
}


#pragma mark -

- (void)dealloc {
	
	[agency release];
	[stop release];
	[super dealloc];
}

@end
