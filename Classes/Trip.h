//
// Trip.h
// kronos
//
// Created by Ljuba Miljkovic on 3/31/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trip : NSObject {

	NSString *startTitle;
	NSString *endTitle;

	NSMutableArray *legs;
	int cost;

	NSTimeInterval duration;

}

@property int cost;
@property NSTimeInterval duration;
@property (nonatomic) NSMutableArray *legs;
@property (nonatomic) NSString *startTitle;
@property (nonatomic) NSString *endTitle;

- (NSString *) durationLabelText;
- (NSString *) costLabelText;

- (void) processData;

@end
