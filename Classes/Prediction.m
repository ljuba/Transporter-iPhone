//
// Prediction.m
// kronos
//
// Created by Ljuba Miljkovic on 3/24/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Prediction.h"

@implementation Prediction

@synthesize arrivals, isError, bartPlatform;

// initializes a prediction object from a predictionRequest object
- (id) initWithPredictionRequest:(PredictionRequest *)request {

	if (self = [super init]) {

		self.stopTag = request.stopTag;
		self.agencyShortTitle = request.agencyShortTitle;
		self.route = request.route;

	}
	return(self);
}


@end
