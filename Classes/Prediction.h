//
//  Prediction.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PredictionRequest.h"

@interface Prediction : PredictionRequest {

	NSMutableDictionary *arrivals;
	NSString *bartPlatform;
	BOOL isError;		//idicates whether there is an error for this route's predictions in the nextbus predictions xml file
}

@property (nonatomic, retain) NSMutableDictionary *arrivals;
@property (nonatomic, retain) NSString *bartPlatform;
@property BOOL isError;


- (id)initWithPredictionRequest:(PredictionRequest *)request;

@end
