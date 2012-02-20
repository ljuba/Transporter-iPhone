//
// BartStopDetails.h
// transporter
//
// Created by Ljuba Miljkovic on 4/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopDetails.h"
#import <UIKit/UIKit.h>

@interface BartStopDetails : StopDetails {

	NSMutableArray *platforms;

}

@property (nonatomic, retain) NSMutableArray *platforms;

@end
