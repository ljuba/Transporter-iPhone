//
//  Trip.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
@property (nonatomic, retain) NSMutableArray *legs;
@property (nonatomic, retain) NSString *startTitle;
@property (nonatomic, retain) NSString *endTitle;

- (NSString *)durationLabelText;
- (NSString *)costLabelText;

- (void)printDescription;
- (void)processData;

@end
