//
// NextBusStopDetails.h
// transporter
//
// Created by Ljuba Miljkovic on 4/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopDetails.h"
#import <UIKit/UIKit.h>

@interface NextBusStopDetails : StopDetails {

	Direction *mainDirection;

}

@property (nonatomic, retain) Direction *mainDirection;

- (void) switchDirections;

@end
