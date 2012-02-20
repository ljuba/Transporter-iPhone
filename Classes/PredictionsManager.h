//
// PredictionsManager.h
// kronos
//
// Created by Ljuba Miljkovic on 3/24/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Agency.h"
#import "PredictionRequest.h"
#import "PredictionsManagerDelegate.h"
#import "Route.h"
#import "Stop.h"
#import <Foundation/Foundation.h>

@interface PredictionsManager : NSObject {

	NSOperationQueue *queue;
	NSMutableDictionary *predictionsStore;

	NSTimer *timer;
}

@property (nonatomic, assign) NSOperationQueue *queue;
@property (nonatomic, retain) NSMutableDictionary *predictionsStore;

@property (nonatomic, assign) NSTimer *timer;

- (void) requestPredictionsForRequests:(NSMutableArray *)requests;
+ (NSString *) predictionKeyFromPrediction:(PredictionRequest *)prediction;
+ (NSString *) predictionKeyFromAgencyShortTitle:(NSString *)agencyShortTitle routeTag:(NSString *)routeTag stopTag:(NSString *)stopTag;
+ (NSString *) predictionKeyFromBARTPrediction:(PredictionRequest *)prediction;
+ (NSString *) arrivalsKeyForDirectionTag:(NSString *)dirTag inRoute:(Route *)route;
+ (NSString *) arrivalsKeyForDirection:(Direction *)direction;
+ (Direction *) directionWithArrivalsKey:(NSString *)key inRoute:(Route *)route;
+ (NSString *) arrivalsKeyForDirectionTag:(NSString *)dirTag routeTag:(NSString *)routeTag agencyShortTitle:(NSString *)agencyShortTitle;

+ (NSDictionary *) filterPredictions:(NSDictionary *)predictions ForStop:(Stop *)stop;

- (void) didReceivePredictions:(NSDictionary *)predictions;
- (void) purgePredictionsStore;

@end
