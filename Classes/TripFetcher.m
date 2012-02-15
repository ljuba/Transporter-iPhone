//
//  TripFetcher.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripFetcher.h"
#import "TouchXML.h"
#import "kronosAppDelegate.h"

#import "Trip.h"
#import "TransitLeg.h"
#import "WalkingLeg.h"
#import <CoreLocation/CoreLocation.h>
#import "DataHelper.h"
#import "NSString+PercentEncode.h"

@implementation TripFetcher


//go to jerry's server and fetch the trips...
- (void)fetchTripsForRequest:(NSMutableDictionary *)tripRequest {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
		
	//base url. contact ljuba.miljkovic@gmail.com if you want to implement real-time trip planning
	NSMutableString *urlString = [NSMutableString stringWithString:@"urlToJerry'sSecretTripPlanner"];
	
	//SETUP URL WITH EITHER LOCATIONS OR ADDRESSES
	
	//used in the trip details view
	NSString *startTitle;
	NSString *endTitle;
	
	id start = [tripRequest objectForKey:@"start"];
	id end = [tripRequest objectForKey:@"end"];
	
	//start
	if ([start isKindOfClass:[NSString class]]) {
		
		NSString *startAddress = [(NSString *)start percentEncode];
		
		[urlString appendFormat:@"&startAdd=%@", startAddress];
		
		startTitle = startAddress;
	}
	else if ([start isMemberOfClass:[CLLocation class]]) {
		
		CLLocation *startLocation = (CLLocation *)start;
		
		NSString *startLat = [NSString stringWithFormat:@"%f",startLocation.coordinate.latitude];
		NSString *startLon = [NSString stringWithFormat:@"%f",startLocation.coordinate.longitude];		
		
		[urlString appendFormat:@"&startLat=%@&startLon=%@", startLat, startLon];
		
		startTitle = @"Current Location";
	}
	
	//end
	if ([end isKindOfClass:[NSString class]]) {
		
		NSString *endAddress = [(NSString *)end percentEncode];
		
		[urlString appendFormat:@"&endAdd=%@", endAddress];	
		
		endTitle = endAddress;
	}
	else if ([end isMemberOfClass:[CLLocation class]]) {
		
		CLLocation *endLocation = (CLLocation *)end;
		
		NSString *endLat = [NSString stringWithFormat:@"%f",endLocation.coordinate.latitude];
		NSString *endLon = [NSString stringWithFormat:@"%f",endLocation.coordinate.longitude];		
		
		[urlString appendFormat:@"&endLat=%@&endLon=%@", endLat, endLon];
		
		endTitle = @"Current Location";
		
	}
	
	NSLog(@"%@", urlString); /* DEBUG LOG */
	
	
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	//get the contents of the URL
	NSError *error;
	CXMLDocument *predictionsDocument = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error] autorelease];
	[url release];
	
	if (error != nil) {
		
		error = [NSError errorWithDomain:@"tripPlanner" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Cannot access server." forKey:@"message"]];
		
		UINavigationController *navController = (UINavigationController *)appDelegate.tabBarController.selectedViewController;
		
		if([navController.topViewController respondsToSelector:@selector(reportRoutingError:)]){
			
			[navController.topViewController performSelectorOnMainThread:@selector(reportRoutingError:) withObject:error waitUntilDone:YES];
			
		}
		
		[pool drain];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		return;
	}
	
	//PARSE THE RETURNED PREDICTIONS XML FILE

	//stores the Trip objects that are created from the XML data
	NSMutableArray *trips = [[[NSMutableArray alloc] init] autorelease];
	
	//the xml trip (completeRoute-cR) nodes
	NSArray *completeRouteNodes = [predictionsDocument nodesForXPath:@"/Ro/cR" error:nil];
	
	if ([completeRouteNodes count] == 0) {
		
		error = [NSError errorWithDomain:@"tripPlanner" code:2 userInfo:[NSDictionary dictionaryWithObject:@"Transporter only supports trips within San Francisco (inc. Treasure Island, Marin Headlands). \n\n We're working to improve this." forKey:@"message"]];
		
		UINavigationController *navController = (UINavigationController *)appDelegate.tabBarController.selectedViewController;
		
		if([navController.topViewController respondsToSelector:@selector(reportRoutingError:)]){
			
			[navController.topViewController performSelectorOnMainThread:@selector(reportRoutingError:) withObject:error waitUntilDone:YES];
			
		}
		
		[pool drain];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		return;
		
	}
		
	NSLog(@"%@", @"GOT THE XML"); /* DEBUG LOG */
	
	for(CXMLNode *completeRouteNode in completeRouteNodes) {
		//create Trip object for this run through the loop
		Trip *trip = [[Trip alloc] init];
		trip.startTitle = startTitle;
		trip.endTitle = endTitle;
		trip.cost = [[[[completeRouteNode nodesForXPath:@"./m" error:nil] objectAtIndex:0] stringValue] intValue];
		
		//go through all of this route's children and create the appropriate trip legs
		for(CXMLNode *child in completeRouteNode.children) {
		
			//walking leg
			if ([[child name] isEqual:@"w"]) {
				
				WalkingLeg *walkingLeg = [[WalkingLeg alloc] init];
				
				NSString *durationString = [[[child nodesForXPath:@"./tr" error:nil] objectAtIndex:0] stringValue];
				walkingLeg.duration = [durationString doubleValue]*60;
								
				//set the starting location if it exists
				NSArray *sl = [child nodesForXPath:@"./s/l" error:nil];
				NSArray *so = [child nodesForXPath:@"./s/o" error:nil];
				if ([sl count] != 0 && [so count] != 0) {
					CLLocationCoordinate2D startLocation;
					startLocation.latitude = [[[sl objectAtIndex:0] stringValue] doubleValue]; 
					startLocation.longitude = [[[so objectAtIndex:0] stringValue] doubleValue];
					walkingLeg.startLocationCoordinate = startLocation;
				}
				
				//set the end location if it exists
				NSArray *el = [child nodesForXPath:@"./e/l" error:nil];
				NSArray *eo = [child nodesForXPath:@"./e/o" error:nil];
				if ([el count] != 0 && [eo count] != 0) {
					CLLocationCoordinate2D endLocation;
					endLocation.latitude = [[[el objectAtIndex:0] stringValue] doubleValue]; 
					endLocation.longitude = [[[eo objectAtIndex:0] stringValue] doubleValue];
					walkingLeg.endLocationCoordinate = endLocation;
				}
				
				[trip.legs addObject:walkingLeg];
				[walkingLeg release];
				continue;
				
			}
			//onStop
			else if ([[child name] isEqual:@"n"]){
				
				TransitLeg *transitLeg = [[TransitLeg alloc] init];

				//get agency
				NSString *agencyShortTitle = [[[[child nodesForXPath:@"agency" error:nil] objectAtIndex:0] stringValue] lowercaseString];
				NSString *stopTag = [[[child nodesForXPath:@"./p" error:nil] objectAtIndex:0] stringValue];
				
				if ([agencyShortTitle isEqualToString:@"bart"]) {
					NSString *dirTitle = [[[child nodesForXPath:@"./d" error:nil] objectAtIndex:0] stringValue];
					
					// Hackity hack hack!
					// BayTripper reports SFO/Millbrae but BART reports SFIA/Millbrae
					if ([dirTitle isEqualToString:@"SFO/Millbrae"]) {
						dirTitle = @"SFIA/Millbrae";
					}
					
					NSMutableString *stopName = [NSMutableString stringWithString:[[[child nodesForXPath:@"./a" error:nil] objectAtIndex:0] stringValue]];
					[stopName replaceOccurrencesOfString:@" BART" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [stopName length])];					
					[transitLeg setBartTransitInfoWithDirectionTitle:dirTitle destinationStopTag:stopTag stopTitle:stopName];
					
				}
				else {					
					NSString *dirTag = [[[child nodesForXPath:@"./d" error:nil] objectAtIndex:0] stringValue];
					NSString *routeTag = [[[child nodesForXPath:@"./b" error:nil] objectAtIndex:0] stringValue];	
					NSString *vehicleId = [[[child nodesForXPath:@"./v" error:nil] objectAtIndex:0] stringValue];
					[transitLeg setTransitInfoWithAgencyShortTitle:agencyShortTitle routeTag:routeTag directionTag:dirTag stopTag:stopTag vehicleId: vehicleId];
				}

				//get the departure time
				NSString *startDateString = [[[child nodesForXPath:@"./c" error:nil] objectAtIndex:0] stringValue];
				NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[startDateString integerValue]];
				transitLeg.startDate = startDate;
				
				[trip.legs addObject:transitLeg];
				[transitLeg release];
				

			}
			//offStop. find the last leg (should be incomplete transit leg) and add the destination stop and time
			else if ([[child name] isEqual:@"f"]){
				
				TransitLeg *incompleteLeg = [trip.legs lastObject];
				
				if (incompleteLeg.endStop != nil) {
					
					NSLog(@"MAJOR PROBLEM" ); /* DEBUG LOG */
					
				}
				
				NSString *agencyShortTitle = [[[[child nodesForXPath:@"agency" error:nil] objectAtIndex:0] stringValue] lowercaseString];
				
				if ([agencyShortTitle isEqualToString:@"bart"]) {
					
					NSMutableString *stopName = [NSMutableString stringWithString:[[[child nodesForXPath:@"./a" error:nil] objectAtIndex:0] stringValue]];
					[stopName replaceOccurrencesOfString:@" BART" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [stopName length])];
				
					Stop *stop = [DataHelper bartStopWithName:stopName];
					incompleteLeg.endStop = stop;
					
				}
				else {
					
					NSString *stopTag = [[[child nodesForXPath:@"./p" error:nil] objectAtIndex:0] stringValue];
					[incompleteLeg setEndStopWithTag:stopTag];
					
				}
				
				NSString *endDateString = [[[child nodesForXPath:@"./c" error:nil] objectAtIndex:0] stringValue];
				NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[endDateString integerValue]];
				incompleteLeg.endDate = endDate;
				

			}
			
		}	//end completeRouteNode.children loop
	
		[trip processData];		//calculated start/end times from the trip legs
		[trips addObject:trip];
		[trip release];
		
	}	//end completeRouteNodes loop
	
	
	NSLog(@"Number of trips: %d", [trips count]); /* DEBUG LOG */
	for (Trip *trip in trips) {
		
		[trip printDescription];
		
	}
	
	
	//find the topmost view controller and see if it responds to "setupTripOverview:"
	//if so, send it the current predictions
	
	
	UINavigationController *navController = (UINavigationController *)appDelegate.tabBarController.selectedViewController;
	
	if([navController.topViewController respondsToSelector:@selector(setupTripOverview:)]){
		
		[navController.topViewController performSelectorOnMainThread:@selector(setupTripOverview:) withObject:trips waitUntilDone:YES];
		
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[pool drain];
	
}


@end
