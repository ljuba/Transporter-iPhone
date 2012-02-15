//
//  PredictionsManager.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PredictionsManager.h"
#import "PredictorOperation.h"
#import "Direction.h"
#import "DataHelper.h"
#import "kronosAppDelegate.h"

@implementation PredictionsManager

@synthesize queue, predictionsStore, timer;

- (id)init {
	
	if (self = [super init]) {
		queue = [[NSOperationQueue alloc] init];
		predictionsStore = [[NSMutableDictionary alloc] init];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(purgePredictionsStore) userInfo:nil repeats:YES];
	}
	
	return self;
	
}

//empty the predictions store 10 seconds after any predictions request occurs
- (void)purgePredictionsStore {
	
	[predictionsStore removeAllObjects];
	
}

//all predictions are first sent here, where they added to the cache of predictions and sent to the topmost view controller
- (void)didReceivePredictions:(NSDictionary *)predictions {
	
	[predictionsStore addEntriesFromDictionary:predictions];
	
	//reset the timer to purge the predictions store every time new predictions come in
	[timer invalidate];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(purgePredictionsStore) userInfo:nil repeats:YES];
	
	//find the topmost view controller and see if it responds to "didReceivePredictions"
	//if so, send it the current predictions

	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	UINavigationController *navController = (UINavigationController *)appDelegate.tabBarController.selectedViewController;
	
	if([navController.topViewController respondsToSelector:@selector(didReceivePredictions:)]){
			
		[navController.topViewController performSelectorOnMainThread:@selector(didReceivePredictions:) withObject:predictions waitUntilDone:YES];
		
	}

	//if there was an error prediction in the predictions that just arrived, they would have been sent to the top view controller
	//we don't want them in the predictionStop permanently, so just remove it now.
	[predictionsStore removeObjectForKey:@"error"];

}


//fetches arrivals data from NextBus or BART and sends them back to the topmost viewcontroller
- (void)requestPredictionsForRequests:(NSMutableArray *)requests {

	//since this method is run in a spearate thread, it needs its own autorelease pool
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//FIRST, SEARCH FOR THOSE PREDICTIONS IN THE PREDICTIONS STORE
	//IF THEY'RE NOT THERE, ONLY THEN MAKE AN INTERNET REQUEST
	
	NSMutableArray *remainingRequests = [NSMutableArray array];
	NSMutableDictionary *foundPredictions = [NSMutableDictionary dictionary]; 
	
	NSLog(@"STORE: %@", predictionsStore); /* DEBUG LOG */
	
	for (PredictionRequest *request in requests) {
		
		NSString *predictionKey;

		Prediction *prediction;
		
		if ([request.agencyShortTitle isEqualToString:@"bart"]) {
			
			predictionKey = request.stopTag;
			prediction = [predictionsStore objectForKey:predictionKey];
			
		}
		else {
			predictionKey = [PredictionsManager predictionKeyFromPrediction:request];
			
			prediction = [predictionsStore objectForKey:predictionKey];
			
		}
		
		if (prediction != nil) {
			
			[foundPredictions setObject:prediction forKey:predictionKey];
			
		}
		else {
			[remainingRequests addObject:request];
		}

	}
	
	//SEND ANY FOUND PREDICTIONS TO THE TOPMOST VIEW CONTROLLER
	
	if ([foundPredictions count] > 0) {
		
		kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		UINavigationController *navController = (UINavigationController *)appDelegate.tabBarController.selectedViewController;
		
		if([navController.topViewController respondsToSelector:@selector(didReceivePredictions:)]){
			
			[navController.topViewController performSelectorOnMainThread:@selector(didReceivePredictions:) withObject:foundPredictions waitUntilDone:YES];
			
		}
		
		NSLog(@"RETURNED PREDICTIONS FROM STORE"); /* DEBUG LOG */

	}
	
	if ([remainingRequests count] == 0) {
		
		NSLog(@"NO REMAINING PREDICTIONS"); /* DEBUG LOG */
		[pool release];
		return;
	}

	//THE REST OF THE REQUESTS GET FETCHED FROM THE INTERNET
	
	//show network indicator when requesting predictions
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSMutableArray *bartRequests = [NSMutableArray array];
	NSMutableArray *acTransitRequests = [NSMutableArray array];
	NSMutableArray *sfMuniRequests = [NSMutableArray array];
	
	//separate requests by agency so we can request them separately (in parallel!)
	for (PredictionRequest *request in remainingRequests) {
		
		if ([request.agencyShortTitle isEqual:@"sf-muni"]) {
			[sfMuniRequests addObject:request];
		}
		else if ([request.agencyShortTitle isEqual:@"actransit"]) {
			[acTransitRequests addObject:request];
		}
		else if ([request.agencyShortTitle isEqual:@"bart"]) {
			[bartRequests addObject:request];
		}
	}
	
	
	PredictorOperation *acTransitPredictorOperation = [[PredictorOperation alloc] initWithAgencyShortTitle:@"actransit" requests:acTransitRequests recipient:self];
	PredictorOperation *sfMuniPredictorOperation = [[PredictorOperation alloc] initWithAgencyShortTitle:@"sf-muni" requests:sfMuniRequests recipient:self];
	
	//submit operations to queue if there are requests
	if ([sfMuniRequests count] != 0) {
		[queue addOperation:sfMuniPredictorOperation];
	}
	if ([acTransitRequests count] != 0) {
		[queue addOperation:acTransitPredictorOperation];
	}
	
	//bart can only had a one request at a time (i.e. one stop at a time), so create separate bart operations for each stop
	//create prediction operation for each agency	
	if ([bartRequests count] != 0) {
		
		for (PredictionRequest *request in bartRequests) {
			
			PredictorOperation *bartPredictorOperation = [[PredictorOperation alloc] initWithAgencyShortTitle:@"bart" requests:[NSArray arrayWithObject:request] recipient:self];
			
			[queue addOperation:bartPredictorOperation];
			[bartPredictorOperation release];
		
		}
	}
	
	[acTransitPredictorOperation release];
	[sfMuniPredictorOperation release];
	
	[pool release];
	

}

#pragma mark -
#pragma mark Prediction Keys

+ (NSString *)predictionKeyFromPrediction:(PredictionRequest *)prediction {
	
	return [self predictionKeyFromAgencyShortTitle:prediction.agencyShortTitle routeTag:prediction.route.tag stopTag:prediction.stopTag];
	
}

+ (NSString *)predictionKeyFromAgencyShortTitle:(NSString *)agencyShortTitle routeTag:(NSString *)routeTag stopTag:(NSString *)stopTag {
	
	return [NSString stringWithFormat:@"%@^%@^%@",agencyShortTitle,routeTag,stopTag];
	
	
}

//BART predictions don't have routeTags, so we use the destinationTag instead here
+ (NSString *)predictionKeyFromBARTPrediction:(PredictionRequest *)prediction {
	
	return [self predictionKeyFromAgencyShortTitle:prediction.agencyShortTitle routeTag:nil stopTag:prediction.stopTag];
		
}

+ (NSString *)arrivalsKeyForDirectionTag:(NSString *)dirTag inRoute:(Route *)route {
	
	NSString *_dirTag = [[dirTag retain] autorelease];
	Route *_route = [[route retain] autorelease];
	
	for (Direction *direction in _route.directions) {
		
		if ([direction.tag isEqualToString:_dirTag]) {
			
			return [self arrivalsKeyForDirection:direction];
			
		}
		
	}
	
	return nil;
}


+ (NSString *)arrivalsKeyForDirection:(Direction *)direction {
	
	return [NSString stringWithFormat:@"%@^%@",direction.name, direction.title];
	
}

+ (NSString *)arrivalsKeyForDirectionTag:(NSString *)dirTag routeTag:(NSString *)routeTag agencyShortTitle:(NSString *)agencyShortTitle {
	
	NSString *_dirTag = [[dirTag retain] autorelease];
	NSString *_routeTag = [[routeTag retain] autorelease];
	NSString *_agencyShortTitle = [[agencyShortTitle retain] autorelease];
	
	Route *route = [DataHelper routeWithTag:_routeTag inAgencyWithShortTitle:_agencyShortTitle];
	
	return [self arrivalsKeyForDirectionTag:_dirTag inRoute:route];
	
}

+ (Direction *)directionWithArrivalsKey:(NSString *)key inRoute:(Route *)route {
	
	NSString *_key = [[key retain] autorelease];
	Route *_route = [[route retain] autorelease];
	
	NSString *directionName = [[_key componentsSeparatedByString:@"^"] objectAtIndex:0];
	NSString *directionTitle = [[_key componentsSeparatedByString:@"^"] objectAtIndex:1];
	
	for (Direction *direction in _route.directions) {
		
		if ([direction.name isEqualToString:directionName] && [direction.title isEqualToString:directionTitle]) {
			
			return direction;
			
		}
		
	}
	
	return nil;
	
}

//takes a predictions dictionary and returns one with only predictions for that stop
+ (NSDictionary *)filterPredictions:(NSDictionary *)predictions ForStop:(Stop *)stop {
	
	NSString *stopTag = stop.tag;
	NSString *agencyShortTitle = [[DataHelper agencyFromStop:stop] shortTitle];
		
	NSArray *predictionsKeys = [predictions allKeys];
	
	NSPredicate *agencyFilter = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@",agencyShortTitle];
	NSPredicate *stopFilter = [NSPredicate predicateWithFormat:@"SELF ENDSWITH %@",stopTag];
	
	NSMutableArray *filteredKeys = [NSMutableArray arrayWithArray:[predictionsKeys filteredArrayUsingPredicate:agencyFilter]];
	[filteredKeys filterUsingPredicate:stopFilter];
	

	NSMutableDictionary *filteredPredictions = [NSMutableDictionary dictionary];
	
	for (NSString *key in filteredKeys) {
			
		[filteredPredictions setObject:[predictions objectForKey:key] forKey:key];
		
	}
	
	if ([filteredPredictions count] == 0) {
		return nil;
	}
	
	return filteredPredictions;
	
	
	
	
	
	
}

- (void)dealloc {
	
	[queue release];
	[predictionsStore release];
	[timer release];
	
	[super dealloc];
}

@end
