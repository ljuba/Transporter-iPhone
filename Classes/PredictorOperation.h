//
// Predictor.h
// Fetches Predictions from BART and NEXTBUS
//
// Created by Ljuba Miljkovic on 3/24/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Prediction.h"
#import "PredictionsManager.h"
#import <Foundation/Foundation.h>

@interface PredictorOperation : NSOperation {

	NSArray *requests;
	PredictionsManager *predictionsManager;
	NSString *agencyShortTitle;

}

@property (nonatomic) NSArray *requests;
@property (nonatomic) PredictionsManager *predictionsManager;
@property (nonatomic) NSString *agencyShortTitle;

- (id) initWithAgencyShortTitle:(NSString *)_agencyShortTitle requests:(NSArray *)_requests recipient:(id)_recipient;

- (NSDictionary *) fetchNextBusPredictions;
- (NSDictionary *) fetchBARTPredictions;

@end
