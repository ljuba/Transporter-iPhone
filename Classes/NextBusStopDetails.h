//
// NextBusStopDetails.h
// transporter
//
// Created by Ljuba Miljkovic on 4/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopDetails.h"
#import <UIKit/UIKit.h>

@interface NextBusStopDetails : StopDetails

@property (nonatomic, strong) Direction *mainDirection;

- (id)initWithStop:(Stop *)newStop mainDirection:(Direction *)newMainDirection;
- (void) switchDirections;

@end
