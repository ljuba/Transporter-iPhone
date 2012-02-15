//
//  DataImporter.m
//  BATransit
//
//  Created by Ljuba Miljkovic on 11/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DataImporter.h"
#import <CoreLocation/CoreLocation.h>

@implementation DataImporter

+ (void)importTransitData {
	
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	appDelegate.importing = YES;
	
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	NSLog(@"importing transit information...");
	
	NSArray *agencyShortTitles = [NSArray arrayWithObjects:@"actransit",@"sf-muni",@"bart",nil];
	
	
	//run this for each transit file
	for (NSString *agencyShortTitle in agencyShortTitles) {
	
		//file containing completel sf muni and ac transit data
		NSString *filePath = [[NSBundle mainBundle] pathForResource:agencyShortTitle ofType:@"xml"];  
		NSData *transitData = [NSData dataWithContentsOfFile:filePath]; 
		
		//get the agency node (root node)
		CXMLDocument *transitParser = [[[CXMLDocument alloc] initWithData:transitData options:0 error:nil] autorelease];
		NSArray *agencyNodes = [transitParser nodesForXPath:@"/agency" error:nil];
		CXMLElement *agencyElement = [agencyNodes objectAtIndex:0];
		
		//get agency info
		CXMLNode *agencyTitle = [agencyElement attributeForName:@"title"];
	
		NSLog(@"%@, %@", [agencyTitle stringValue], agencyShortTitle);
	
		//create current agency object to add routes to
		Agency *agency = (Agency *)[NSEntityDescription insertNewObjectForEntityForName:@"Agency" 
															 inManagedObjectContext:managedObjectContext];
		//set current agency properties
		agency.shortTitle = agencyShortTitle;
		agency.title = [agencyTitle stringValue];
		
		//all of the stops in this agency
		NSMutableDictionary *agencyStops = [NSMutableDictionary dictionary];
		
		//IMPORT ALL STOPS
		NSArray *stopNodes = [agencyElement nodesForXPath:@"./stop" error:nil];
		
		for (CXMLElement *stopElement in stopNodes){
			
			//get stop info
			CXMLNode *stopTag = [stopElement attributeForName:@"tag"];
			CXMLNode *stopTitle = [stopElement attributeForName:@"title"];
			CXMLNode *stopGroup = [stopElement attributeForName:@"group"];
			CXMLNode *stopLat = [stopElement attributeForName:@"lat"];
			CXMLNode *stopLon = [stopElement attributeForName:@"lon"];
			
			//create stop object
			Stop *stop = (Stop *)[NSEntityDescription insertNewObjectForEntityForName:@"Stop" 
															   inManagedObjectContext:managedObjectContext];
			stop.tag = [stopTag stringValue];						
			stop.title = [stopTitle stringValue];
			stop.group = [stopGroup stringValue];
			stop.lat = [NSNumber numberWithFloat:[[stopLat stringValue] floatValue]];
			stop.lon = [NSNumber numberWithFloat:[[stopLon stringValue] floatValue]];
			stop.agency = agency;
			
			//add this stop to the dictionary of stops
			[agencyStops setObject:stop forKey:stop.tag];
			
		}
		
		//go through the stops again, this time link them with their reverseStops (found in the agencyStops dictionary)
		for (CXMLElement *stopElement in stopNodes) {
			
			//get stop info
			CXMLNode *stopTag = [stopElement attributeForName:@"tag"];
			CXMLNode *reverseStopTag = [stopElement attributeForName:@"oppositeStopTag"];
			
			Stop *stop = [agencyStops objectForKey:[stopTag stringValue]];
			stop.oppositeStop = [agencyStops objectForKey:[reverseStopTag stringValue]];
			
		}
		
		
		
		//IMPORT ALL ROUTES
		NSArray *routeNodes = [agencyElement nodesForXPath:@"./route" error:nil];
		
		//will hold the routes for each agency until the set is added to the agency
		NSMutableSet *routesSet = [[NSMutableSet alloc] init];
		
		for (CXMLElement *routeElement in routeNodes) {
			
			//get route info
			CXMLNode *routeTag = [routeElement attributeForName:@"tag"];
			CXMLNode *routeTitle = [routeElement attributeForName:@"title"];
			CXMLNode *routeColor = [routeElement attributeForName:@"color"];
			CXMLNode *routeVehicle = [routeElement attributeForName:@"vehicle"];
			CXMLNode *routeSortOrder = [routeElement attributeForName:@"sortOrder"];
			
			Route *route = (Route *)[NSEntityDescription insertNewObjectForEntityForName:@"Route" 
																  inManagedObjectContext:managedObjectContext];
			//set current route properties
			route.tag = [routeTag stringValue];
			route.title = [routeTitle stringValue];
			route.color = [routeColor stringValue];
			route.vehicle = [routeVehicle stringValue];
			route.agency = agency;
			
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
			[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
			
			route.sortOrder = [formatter numberFromString:[routeSortOrder stringValue]];
			
			[formatter release];
			
			
			NSLog(@"  Route: %@, %@, %@, %@", [routeTag stringValue], [routeTitle stringValue], [route.sortOrder stringValue], [routeVehicle stringValue]);
			
			//find active directions and their stops
			NSArray *directionNodes = [routeElement nodesForXPath:@"./direction" error:nil];
			
			//will hold the directions for each route until the set is added to the route.
			NSMutableSet * directionsSet = [[NSMutableSet alloc] init]; 
			
			//iterate over the active directions for the current route
			for (CXMLElement *directionElement in directionNodes){
				
				//get direction info
				CXMLNode *directionTag = [directionElement attributeForName:@"tag"];
				CXMLNode *directionTitle = [directionElement attributeForName:@"title"];
				CXMLNode *directionName = [directionElement attributeForName:@"name"];
				CXMLNode *directionShow = [directionElement attributeForName:@"show"];

				
				Direction *direction = (Direction *)[NSEntityDescription insertNewObjectForEntityForName:@"Direction" 
																				  inManagedObjectContext:managedObjectContext];
				
				//set current direction properties
				direction.tag = [directionTag stringValue];
				direction.title = [directionTitle stringValue];
				direction.name = [directionName stringValue];
				direction.show = [NSNumber numberWithBool:[[directionShow stringValue] boolValue]];
				direction.route = route;
				
				NSLog(@"     -Direction: %@, %@, %@", [directionTag stringValue], [directionTitle stringValue], [directionName stringValue]);
			
				//link the stops in the direction to the stops in the agencyStops dictionary
				
				//array to store the order of stops for each direction
				NSMutableArray *stopOrder = [[NSMutableArray alloc] init];
				
				//all of the stop for this direction, while will be added to the direction when it's full
				NSMutableSet *stopsSet = [[NSMutableSet alloc] init];
				
				//go through all of the stops in each direction
				for (CXMLElement *stopElement in [directionElement children]){
					
					//Only interested in the CXMLElements, not the CXMLNodes
					if ([stopElement isMemberOfClass:[CXMLElement class]]) {
				
						//tag of the stop in the current direction
						NSString *stopTag = [[stopElement attributeForName:@"tag"] stringValue];
						//NSLog(@"         %@", stopTag); /* DEBUG LOG */
						//fetch that stop from the agencyStops dictionary
						Stop *stop = [agencyStops objectForKey:stopTag];
						
						//add the stop to the collection of stops for this direction
						[stopsSet addObject:stop];
						
						//add this direction to this stop
						NSMutableSet *existingDirectionsSet = [NSMutableSet setWithSet:stop.directions];
						[existingDirectionsSet addObject:direction];
						stop.directions = existingDirectionsSet;
						
						//add stop tag to the array that keeps the stop order for that direction
						[stopOrder addObject:stopTag];
					}	
				
				
				}	//end (stops in a direction) loop
				

				//add the current direction to the directionSet to be used by the route
				[directionsSet addObject:direction];
				
				//set the stops and order for the current direction to the accumulated stops for it
				direction.stops = stopsSet;
				[stopsSet release];
				
				direction.stopOrder = stopOrder;
				
			}	//end direction loop
		
			//set the directions for a route
			route.directions = directionsSet;
			[directionsSet release];
			
			//add the current route to the routesSet for use in the agency
			[routesSet addObject:route];
			
			
		}	//end route loop
		
		//set the routes for the agency
		agency.routes = routesSet;
		[routesSet release];
		
		NSError *error;
		if (![managedObjectContext save:&error]) {
			NSLog(@"There was an error saving the routes, %@", error);
		}
		
		
		
	} //end of agency loop
	
	appDelegate.importing = NO;
	
	NSLog(@"Done!");
		
}

//returns the path that a line passes through
//+ (NSArray *)pathForLine:(NSString *)agency routeTag:(NSString *)line {
//	NSString *urlString = [NSString stringWithFormat:@"http://www.nextbus.com/s/COM.NextBus.Servlets.XMLFeed?command=routeConfig&a=%@&r=%@&t=0", agency, line];
//	NSURL *url = [NSURL URLWithString: urlString];
//	
//	CXMLDocument *routeParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
//	NSArray *directionNodes = [routeParser nodesForXPath:@"//direction" error:nil];
//	
//	NSMutableArray *routePath = [[[NSMutableArray alloc] initWithCapacity:1] autorelease]; //will hold the path to return
//	NSMutableArray *directions = [[NSMutableArray alloc] initWithCapacity:1];
//	
//	//cycles through all the elements of the name 'direction'
//	for (CXMLElement *directionElement in directionNodes) {
//		
//		//get data from the element
//		CXMLNode *useForUI = [directionElement attributeForName:@"useForUI"];
//		
//		NSString *use = [useForUI stringValue];
//		//get only data that has the value of 'true' for useForUI
//		if ([use isEqualToString:@"true"])
//		{
//			//get dirTag
//			CXMLNode *tagNode = [directionElement attributeForName:@"tag"];
//			
//			NSString *tag = [tagNode stringValue];
//			//add string to an array
//			[directions addObject:tag];			
//		}
//	}
//	
//	//NSLog(@"Directions found: %@", directions);
//	//get all paths from the document
//	NSArray *pathNodes = [routeParser nodesForXPath:@"//path" error:nil];
//	
//	//get path for each direction
//	for (NSString *direction in directions ) {
//		
//		NSMutableArray *directionPath = [[NSMutableArray alloc] initWithCapacity:1];
//		
//		//for each of the path nodes, check if it is for the given direction
//		for (int index = 0; index < [pathNodes count]; index++) {
//			CXMLNode *pathNode = [pathNodes objectAtIndex:index];
//			
//			BOOL allTagsAdded = NO;
//			BOOL found = NO;
//			int childIndex = 0;
//			
//			NSMutableDictionary *path = [[NSMutableDictionary alloc] init];
//			NSMutableArray *coordinates = [[NSMutableArray alloc] initWithCapacity:1];
//			
//			//check if it is for the given direction. if it is, get the path
//			while ((!allTagsAdded || found) && childIndex < [pathNode childCount]) {
//				
//				CXMLNode *childNode = [pathNode childAtIndex:childIndex];
//				
//				if([childNode isKindOfClass:[CXMLElement class]])
//				{
//					
//					CXMLElement *child = (CXMLElement *)childNode;
//					
//					if([[child name] isEqualToString:@"tag"])
//					{
//						NSString *idValue = [[child attributeForName:@"id"] stringValue];
//						
//						if([idValue hasPrefix:direction])
//						{
//							int length = [direction length];
//							
//							NSString *idSubstr = [idValue substringFromIndex:length];
//							NSArray *idParts = [idSubstr componentsSeparatedByString:@"_"];
//							
//							NSString *pathIndex = [idParts objectAtIndex:0];
//							
//							
//							[path setObject:pathIndex forKey:@"index"];
//							found = YES;
//						}
//					}
//					else {
//						allTagsAdded = YES;
//						
//						//get path if direction is found in the stop entries
//						if (found) {
//							CXMLNode *latNode = [child attributeForName:@"lat"];
//							CXMLNode *lonNode = [child attributeForName:@"lon"];
//							
//							CLLocation *location = [[CLLocation alloc] initWithLatitude:[[latNode stringValue]doubleValue] longitude:[[lonNode stringValue] doubleValue]];
//							
//							[coordinates addObject:location];
//							[location release];
//						}
//					}
//				}
//				childIndex += 1;
//			}
//			
//			//add coordinates to the path, and then add the path to the directionPath in order of index
//			if (found) {
//				[path setObject:coordinates forKey:@"coordinates"];
//				
//				//if direction path is empty, add path
//				if ([directionPath count] == 0) {
//					[directionPath addObject:path];
//				}
//				else {
//					BOOL added = NO;
//					int arrIndex = 0;
//					
//					int count = [directionPath count];
//					
//					//if not, iterate through direction path and insert path in correct index spot
//					while((arrIndex < count) && !added) {
//						NSMutableDictionary *item = [directionPath objectAtIndex:arrIndex];
//						
//						if ([[path objectForKey:@"index"] intValue] > [[item objectForKey:@"index"] intValue]) {
//							[directionPath insertObject:path atIndex:arrIndex];
//							added = YES;
//						}
//						
//						arrIndex += 1;
//					}
//					
//					if(!added)
//						[directionPath addObject:path];
//				}
//				
//				[coordinates release];
//				[path release];
//			}
//			
//		}
//		
//		//build final path
//		NSMutableDictionary *finalPath = [[NSMutableDictionary alloc] init];
//		
//		[finalPath setObject:direction forKey:@"direction"];
//		NSMutableArray *pathPoints = [[NSMutableArray alloc] initWithCapacity:1];
//		
//		for (int i = [directionPath count] - 1; i >= 0; i--) {
//			NSMutableDictionary *item = [directionPath objectAtIndex:i];
//			NSMutableArray *pathPointsFromItem = [item objectForKey:@"coordinates"];
//			
//			for(CLLocation *pathCoordinates in pathPointsFromItem) {
//				[pathPoints addObject:pathCoordinates];
//			}
//			
//		}
//		
//		[finalPath setObject:pathPoints forKey:@"pathPoints"];
//		[routePath addObject:finalPath];
//		[finalPath release];
//		[pathPoints release];
//		[directionPath release];
//	}
//	
//	[directions release];
//	
//	return routePath;
//}



@end
