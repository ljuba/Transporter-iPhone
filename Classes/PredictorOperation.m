//
//  Predictor.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PredictorOperation.h"
#import "TouchXML.h"
#import "PredictionRequest.h"
#import "Direction.h"
#import "NSString+PercentEncode.h"

@implementation PredictorOperation

@synthesize agencyShortTitle, requests, predictionsManager;

- (id)initWithAgencyShortTitle:(NSString *)_agencyShortTitle requests:(NSArray *)_requests recipient:(PredictionsManager *)_recipient {

	 if (self = [super init]) {
		 self.requests = _requests;
		 self.predictionsManager = _recipient;
		 self.agencyShortTitle = _agencyShortTitle;
	 }
	
	return self;
}


//run this method when the predictor is added to the queue
- (void)main {
	
	//the predictions manager sends a request for each agency whether or not there are any requests for it.
	//only fetches predictions for requests that aren't empty.
	if ([requests count] == 0) {

		//if this is the last operation, turn off the network activity monitor
		if ([[predictionsManager.queue operations] count] <= 1) {
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
		return;
	}
	
	NSDictionary *fetchedPredictions;
	
	if (self.agencyShortTitle == @"actransit" || self.agencyShortTitle == @"sf-muni") {
		fetchedPredictions = [self fetchNextBusPredictions];
	}
	else {
		fetchedPredictions = [self fetchBARTPredictions];
	}
	
	
	//sends predictions back to predictionsManager
	[predictionsManager performSelectorOnMainThread:@selector(didReceivePredictions:) withObject:fetchedPredictions waitUntilDone:YES];
	
	//if this is the last operation, turn off the network activity monitor
	if ([[predictionsManager.queue operations] count] <= 1) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

//can only process one request at a time. i.e. one station at a time
- (NSDictionary *)fetchBARTPredictions {
	
	NSString *stopTag = [[requests objectAtIndex:0] stopTag];
	
    //BART PUBLIC API KEY. YOU MIGHT WANT TO USE YOUR OWN
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://api.bart.gov/api/etd.aspx?cmd=etd&orig=%@&key=MW9S-E7SL-26DU-VV8V", stopTag];
	
	NSLog(@"%@", urlString); /* DEBUG LOG */
		
	//have to replace the unicode character | with escape characters 
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	
	//get the contents of the URL
	NSError *error;
	CXMLDocument *predictionsDocument = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error] autorelease];
	[url release];
	
	if (error != nil) {
		
		error = [NSError errorWithDomain:@"predictor" code:1 userInfo:[NSDictionary dictionaryWithObject:@"No Internet Connection" forKey:@"message"]];
		
		return [NSDictionary dictionaryWithObject:error forKey:@"error"];;
		
	}
	
	//PARSE THE RETURNED PREDICTIONS XML FILE
	
	//array of prediction dictionaries to be returned at the end of this method
	NSMutableDictionary *fetchedPredictions = [NSMutableDictionary dictionary];
	
	//the xml nodes that contain arrivals for a particular stop/route
	NSArray *etdNodes = [predictionsDocument nodesForXPath:@"/root/station/etd" error:nil];
	
	Prediction *prediction = [[Prediction alloc] init];
	prediction.agencyShortTitle = @"bart";
	prediction.stopTag = stopTag;
	
	NSMutableDictionary *arrivals = [[NSMutableDictionary alloc] init];
	
	//create a prediction object for each etdElement
	for (CXMLElement *etdElement in etdNodes) {
		
		NSString *destinationTag = [[[etdElement nodesForXPath:@"./abbreviation" error:nil] objectAtIndex:0] stringValue];
		
		//NSLog(@"%@", destinationStopTag); /* DEBUG LOG */
		
		NSArray *estimates = [etdElement nodesForXPath:@"./estimate" error:nil];
		
		//this is the array that will be the object in the arrivals dictionary.
		NSMutableArray *destinationArrivals = [[NSMutableArray alloc] init];
				
		//gather all the arrivals data (called estimates by BART)
		for (CXMLElement *estimate in estimates) {
						
			NSMutableDictionary *arrival = [[NSMutableDictionary alloc] init];
			for (CXMLElement *item in estimate.children) {
				
				//add all elements from the estimate node to the arrival dictionary
				[arrival setObject:[item stringValue] forKey:[item name]];
		
			}
		
			[destinationArrivals addObject:arrival];
			[arrival release];
			
		}
		
		//once you've created an array with with all the arrival (estimate) objects, create the arrivals dictionary
		[arrivals setObject:destinationArrivals forKey:destinationTag];
		[destinationArrivals release];
		
	}
	
	prediction.arrivals = arrivals;
	[arrivals release];
		
	[fetchedPredictions setObject:prediction forKey:prediction.stopTag];
	[prediction release];
	
	
	for (Prediction *p in [fetchedPredictions allValues]){
		
		//NSLog(@"%@", p.stopTag); /* DEBUG LOG */
		//NSLog(@"-%@", p.arrivals); /* DEBUG LOG */
		
	}
	
	return fetchedPredictions;
	
}

- (NSDictionary *)fetchNextBusPredictions {
	
	//alternative: http://api.nextbusmobile.com:80/xml/feed?apiKey=56b86636-0f57-4439-ae12-eebeea034062&command=predictionsForMultiStops

	NSString *urlString;
	
	if (agencyShortTitle == @"sf-muni") {
		urlString = [NSString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&t=0", agencyShortTitle];
	}
	else {
		urlString = [NSString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=%@&t=0", agencyShortTitle];
	}

	//add the requested stops and lines to the urlString
	for(PredictionRequest *request in requests) {
		
		NSString *stopString;
		
		//SPECIAL STOPS WHERE BOTH CLOCKWISE AND COUNTERCLOCKWISE STOP ON ROUTE 25 // THIS IS BAD BAD BAD!
		NSArray *specialStops = [[NSArray alloc] initWithObjects:@"0303500", @"0303660", @"0303740", @"0303530", @"0303750", @"0303600", @"0303720", @"0301510", @"0306210", @"0306650", @"0306030", @"0305980", @"0303610", @"0303520", @"0303730", @"0303670", @"0303510", nil];
		
		if ([request.route.tag isEqualToString:@"25"] && [specialStops containsObject:request.stopTag]) {
			
			Direction *anyDirection = [request.route.directions anyObject];
			stopString = [NSString stringWithFormat:@"%@|%@|%@", request.route.tag, anyDirection.tag, request.stopTag];
	
		}
		else {
			stopString = [NSString stringWithFormat:@"%@|null|%@", request.route.tag, request.stopTag];
		}
		
		[specialStops release];

        NSString* escapedStopString = [stopString percentEncode];
        urlString = [NSString stringWithFormat:@"%@&stops=%@", urlString, escapedStopString];
	}
	
	//use this to test nextbus error conditions
	//urlString = @"http://www.ljuba.net/error.xml";
    
    NSLog(@"PredictorOperationEscapedURL: %@",urlString);
	
	//have to replace the unicode character | with escape characters 
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	//get the contents of the URL
	NSError *error;
	CXMLDocument *predictionsDocument = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error] autorelease];
	[url release];
	if (error != nil) {
		error = [NSError errorWithDomain:@"predictor" code:1 userInfo:[NSDictionary dictionaryWithObject:@"No Internet Connection" forKey:@"message"]];
		
		return [NSDictionary dictionaryWithObject:error forKey:@"error"];;
		
	}
	
	//PARSE THE RETURNED PREDICTIONS XML FILE
	
	//the xml nodes that contain arrivals for a particular stop/route
	NSArray *predictionsNodes = [predictionsDocument nodesForXPath:@"/body/predictions" error:nil];

	//look for error nodes in the xml file
	NSArray *errorNodes = [predictionsDocument nodesForXPath:@"/body/Error" error:nil];
	
	//if there are no predictions, just errors...
	if ([errorNodes count] > 0 && [predictionsNodes count] == 0) {
		
		error = [NSError errorWithDomain:@"predictor" code:2 userInfo:[NSDictionary dictionaryWithObject:@"Cannot find arrivals. \nThere is a problem with NextBus." forKey:@"message"]];
		
		return [NSDictionary dictionaryWithObject:error forKey:@"error"];;
		
	}
	
	//if there is an error for a specific node, it will have an error tag instead ofa predictions tag. this will find either, so we can indicate an error in the returned prediction
	NSArray *predictionsOrErrorNodes = [predictionsDocument nodesForXPath:@"/body/predictions | /body/Error" error:nil];
	
	//array of prediction dictionaries to be returned at the end of this method
	NSMutableDictionary *fetchedPredictions = [NSMutableDictionary dictionary];
	
	
	//for each predictions node parse all the information and creates a predictions array to add to the request dictionary, which will be added to fetchedPredictions. the predictions node is for a particular stop
	for(CXMLElement *predictionsOrErrorElement in predictionsOrErrorNodes) {
	
		//index of the request in the requests array
		int requestIndex = [predictionsOrErrorNodes indexOfObject:predictionsOrErrorElement];
		
		//create a prediction object from the predictionRequest and the arrivals data or the error
		Prediction *prediction = [[Prediction alloc] initWithPredictionRequest:[requests objectAtIndex:requestIndex]];
				
		//if the element isn't not an error, but an actual predictions element
		if (![[predictionsOrErrorElement name] isEqual:@"Error"]){
			
			//some prediciton elements have more than one direction. save each direction associated with the given route
			NSArray *directionNodes = [predictionsOrErrorElement nodesForXPath:@"./direction" error:nil];
			
			//will store the arrivals for each direction in a given route (key:dirTag. object:directionArrivalsArray)
			NSMutableDictionary *routeArrivals = [[NSMutableDictionary alloc] init];
			
			//save each direction's arrivals with the given route's prediction request
			for (CXMLElement *directionElement in directionNodes) {
				
				NSArray *arrivalNodes = [directionElement nodesForXPath:@"./prediction" error:nil];
				
				NSMutableArray *directionArrivals = [[NSMutableArray alloc] init];
				NSString *arrivalDirTag = nil;
				
				//create an arrival element for each 
				for (CXMLElement *arrivalElement in arrivalNodes) {
					
					//should be the same dirTag for each arrivals element in a direction block
					arrivalDirTag = [[arrivalElement attributeForName:@"dirTag"] stringValue];
					
					//iterate through all the attributes (whatever they may be) for each arrival node and populate two arrays: attribute names, attribute values
					NSMutableArray *attributeNames  = [NSMutableArray array];
					NSMutableArray *attributeValues = [NSMutableArray array];
					
					for (CXMLElement *attributeElement in [arrivalElement attributes]){
						
						[attributeNames addObject:[attributeElement name]];
						[attributeValues addObject:[attributeElement stringValue]];
						
					}
					
					//consolidate the arrivals info into an arrival dictionary object and add it to the arrivals array
					NSDictionary *arrival = [NSDictionary dictionaryWithObjects:attributeValues	forKeys:attributeNames];
					
					//check to see if directionArrials already has and arrivals object with the same vehicleID as this one. (sometimes, predictions are duplicated)
					BOOL arrivalAlreadyExists = NO;
					for (NSDictionary *a in directionArrivals) {
						
						//check that both arrival dictionaries have vehicle IDs
						if ([a objectForKey:@"vehicle"] == nil || [arrival objectForKey:@"vehicle"] == nil) {
							break;
						}
						
						if ([[a objectForKey:@"vehicle"] isEqual:[arrival objectForKey:@"vehicle"]]) {
							arrivalAlreadyExists = YES;
							break;
						}
						
					}
					
					//if the arrival is not a duplciate, add it to the directionArrivals array so it can be linked with the dirTag in routeArrivals
					if (!arrivalAlreadyExists) {
						[directionArrivals addObject:arrival];
					}

				}
				
				//now that we have all the arrivals for a given direction, add it to the routeArrivals dictionary and link with its arrivalsKey
				NSString *arrivalsKey = [PredictionsManager arrivalsKeyForDirectionTag:arrivalDirTag inRoute:prediction.route];	

				if (arrivalsKey != nil) {
					
					[routeArrivals setObject:directionArrivals forKey:arrivalsKey];
					
				}
				
				[directionArrivals release];
				//NSLog(@"%@", directionArrivals); /* DEBUG LOG */
				
			}
			
			prediction.isError = NO;
			prediction.arrivals = routeArrivals;
			[routeArrivals release];

		
		}
		else {
			prediction.isError = YES;
		}

		//add the new prediction (which contains agency/route/direction/stop/arrival/error info) into the fetchedPredictions dictionary with a unique key
		[fetchedPredictions setObject:prediction forKey:[PredictionsManager predictionKeyFromPrediction:prediction]];
		[prediction release];
	}
	
	return fetchedPredictions;
	
}



- (void)dealloc {

	[agencyShortTitle release];
	[requests release];
	
	[super dealloc];
}


@end
