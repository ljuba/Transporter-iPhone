//
//  DataHelper.m
//  kronos
//
//  Created by Ljuba Miljkovic on 4/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "kronosAppDelegate.h"

@implementation DataHelper

+ (Stop *)bartStopWithName:(NSString *)bartStopTitle {
	
	//NSDate *startTime = [NSDate dateWithTimeIntervalSinceNow:0];
	
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
    [request setPredicate: [NSPredicate predicateWithFormat: @"title = %@ AND agency.shortTitle = %@", bartStopTitle, @"bart"]]; 
    
    NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	
	//NSDate *endTime = [NSDate dateWithTimeIntervalSinceNow:0];						   
	//NSTimeInterval duration =  [endTime timeIntervalSinceDate:startTime]; 						   
							   
	//NSLog(@"bartStopWithName: %f",duration);
	
    if (1 == [results count]) {
		[request release];
        return [results objectAtIndex: 0];
    } else {
        NSLog(@"I'm confused");
    }
	
	NSLog(@"ERROR: CAN'T FIND BART STOP WITH TITLE :%@", bartStopTitle); /* DEBUG LOG */
	
	[request release];
	return nil;
	
}


+ (Agency *)agencyWithShortTitle:(NSString *)agencyShortTitle {
	
	//get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Agency" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortTitle=%@",agencyShortTitle];
	[request setPredicate:predicate];
	
	//Receive the results
	NSError *error;
	NSMutableArray *agencies = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (agencies == nil) {
		NSLog(@"Could not fetch agencies!");
		[request release];
		return nil;
	}
	[request release];
	
	Agency *fetchedAgency = [[[agencies objectAtIndex:0] retain] autorelease];
	[agencies release];
	
	return fetchedAgency;
}

+ (Route *)routeWithTag:(NSString *)routeTag inAgency:(Agency *)agency {
	
	NSPredicate *routeFilter = [NSPredicate predicateWithFormat:@"tag == %@",routeTag];
	
	NSArray *routes = [[agency.routes allObjects] filteredArrayUsingPredicate:routeFilter];
	
	if ([routes count] == 0) {
		return nil;
	}
	
	Route *route = [routes objectAtIndex:0];
	return route;

}

+ (Route *)routeWithTag:(NSString *)routeTag inAgencyWithShortTitle:(NSString *)agencyShortTitle {
	
	//get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	[request setPredicate: [NSPredicate predicateWithFormat: @"tag = %@ AND agency.shortTitle = %@", routeTag, agencyShortTitle]]; 
	
	//Receive the results
	NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	
	if (1 == [results count]) {
        [request release];
		return [results objectAtIndex: 0];
    } else {
        NSLog(@"routeWithTag:inAgencyWithShortTitle: I'm confused");
    }
	[request release];
	
	NSLog(@"ERROR: CAN'T FIND ROUTE WITH THAT TAG AND AGENCY SHORT TITLE: %@, %@", routeTag, agencyShortTitle); /* DEBUG LOG */
	return nil;
	
}

+ (Stop *)stopWithTag:(NSString *)stopTag inDirection:(Direction *)direction {
	
	for (Stop *stop in direction.stops) {
		
		if ([stop.tag isEqualToString:stopTag]) {
			
			return stop;
		}
		
	}
	
	return nil;
	
}

+ (Agency *)agencyFromStop:(Stop *)stop {

	Route *route = [[stop.directions anyObject] route];
	Agency *agency = route.agency;
	
	return agency;

}

+ (Direction *)directionWithTag:(NSString *)dirTag inRoute:(Route *)route {
	
	for (Direction *direction in route.directions) {
		
		if ([direction.tag isEqualToString:dirTag]) {
			return direction;
		}
	}

	return nil;
}

+ (NSArray *)bartDirectionsWithTitle:(NSString *)title {
	//get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the directions from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Direction" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title==%@",title];
	[request setPredicate:predicate];
	
	//Receive the results
	NSError *error;
	NSMutableArray *directions = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (directions == nil) {
		NSLog(@"Could not fetch BART directions!");
		[request release];
		return nil;
	}
	[request release];
	return (NSArray *)directions;
}

+ (NSArray *)directionTagsInRoute:(Route *)route thatMatchDirectionName:(NSString *)dirName directionTitle:(NSString *)dirTitle {
	
	NSMutableArray *matchedDirectionTags = [NSMutableArray array];

	
	for (Direction *direction in route.directions) {
		
		//check match to name and title
		if ([direction.name isEqualToString:dirName] && [direction.title isEqualToString:dirTitle]) {
			
			[matchedDirectionTags addObject:direction.tag];
			
		}
				
	}
	
	return (NSArray *)matchedDirectionTags;
	
	
	
}


+ (NSArray *)directionTagsThatMatchDirectionName:(NSString *)dirName directionTitle:(NSString *)dirTitle routeTag:(NSString *)routeTag forAgencyWithShortTitle:(NSString *)agencyShortTitle {
	
	//get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Direction" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@ AND title=%@ AND route.tag=%@ AND route.agency.shortTitle=%@", dirName, dirTitle, routeTag, agencyShortTitle];
	[request setPredicate:predicate];
	
	//Receive the results
	NSError *error;
	NSMutableArray *directions = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (directions == nil) {
		NSLog(@"directionTagsThatMatchDirectionName: Could not fetch directions!");
		[request release];
		return nil;
	}
	[request release];
	
	
	NSMutableArray *matchedDirectionTags = [NSMutableArray array];
	
	for (Direction *direction in directions) {
		
		[matchedDirectionTags addObject:direction.tag];
		
	}
	
	return (NSArray *)matchedDirectionTags;;
}


+ (Destination *)destinationForBARTStopTag:(NSString *)stopTag toStopTag:(NSString *)destinationStopTag {
	
	Stop *stop = [DataHelper stopWithTag:stopTag inAgencyWithShortTitle:@"bart"];
	
	Stop *destinationStop = [DataHelper stopWithTag:destinationStopTag inAgencyWithShortTitle:@"bart"];
	
	return [[[Destination alloc] initWithDestinationStop:destinationStop forStop:stop] autorelease];
	
}


+ (Stop *)stopWithTag:(NSString *)stopTag inAgencyWithShortTitle:(NSString *)agencyShortTitle {
	
	//get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag=%@ AND agency.shortTitle=%@",stopTag,agencyShortTitle];
	[request setPredicate:predicate];
	
	//Receive the results
	NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	
	if (1 == [results count]) {
		[request release];
        return [results objectAtIndex: 0];
    } else {
		NSLog(@"stopWithTag:inAgencyWithShortTitle: I'm confused");
		NSLog(@"Restuls: %@", results);
    }
	[request release];
	
	NSLog(@"ERROR: CAN'T FIND STOP WITH THAT TAG AND AGENCY SHORT TITLE: %@, %@", stopTag, agencyShortTitle); /* DEBUG LOG */
	return nil;
	
}

//return the stop objects given its tag and agency
+ (Stop *)stopWithTag:(NSString *)stopTag inAgency:(Agency *)agency {
		
	//get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Stop" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag=%@ AND agency=%@",stopTag,agency];
	[request setPredicate:predicate];
	
	//Receive the results
	NSError *error = nil;
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
	
	if (1 == [results count]) {
		[request release];
        return [results objectAtIndex: 0];
    } else {
        NSLog(@"stopWithTag:inAgency: I'm confused");
    }
	[request release];
	
	NSLog(@"ERROR: CAN'T FIND STOP WITH THAT TAG AND AGENCY: %@, %@", stopTag, agency.shortTitle); /* DEBUG LOG */
	return nil;
}

+ (void)saveStopObjectIDInUserDefaults:(Stop *)stop {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSURL *stopURI = [[stop objectID] URIRepresentation];
	NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:stopURI];
	[userDefaults setObject:uriData forKey:@"stopURIData"];	
	
	[userDefaults synchronize];
	
	NSLog(@"saved stop with uri: %@", [userDefaults objectForKey:@"stopURIData"]); /* DEBUG LOG */
	
}

+ (void)saveDirectionIDInUserDefaults:(Direction *)direction forKey:(NSString*)key {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSURL *directionURI = [[direction objectID] URIRepresentation];
	NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:directionURI];
	[userDefaults setObject:uriData forKey:key];
	
	//NSLog(@"TEST DIRECTION SAVE: %@", [userDefaults objectForKey:key]); /* DEBUG LOG */
	
}

+ (CLLocation *)locationOfStop:(Stop *)stop {
	
	return [[[CLLocation alloc] initWithLatitude:[stop.lat doubleValue] longitude:[stop.lon doubleValue]] autorelease];
}

//returns an array with the closest stop
+ (NSMutableArray *)findClosestStopsFromLocation:(CLLocation *)location amongStops:(NSArray *)stops count:(int)number{
	
	NSMutableDictionary *stopsByDistance = [[NSMutableDictionary alloc] init];
	
	//create a dictionary of stops where the key is the distance from the location
	for (Stop *stop in stops) {
		
		NSNumber *stopDistance = [NSNumber numberWithDouble:[location distanceFromLocation:[self locationOfStop:stop]]];
		
		[stopsByDistance setObject:stop forKey:stopDistance];
		
	}
	
	//sort an array of keys (distances)
	NSMutableArray *distances = [NSMutableArray arrayWithArray:[stopsByDistance allKeys]];
	
	NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
	[distances sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
	[sorter release];
	
	
	NSMutableArray *closestStops = [NSMutableArray array];
	
	//crate and array of the n closest stops
	for (int i = 0; i < number; i++) {
		
		[closestStops addObject:[stopsByDistance objectForKey:[distances objectAtIndex:i]]];
		
	}
	
	[stopsByDistance release];
	
	return closestStops;
	
}

+ (NSArray *)uniqueRoutesForStop:(Stop *)stop {
	
	NSMutableArray *routes = [NSMutableArray array];
	
	for (Direction *direction in stop.directions) {
		
		if (![routes containsObject:direction.route]) {

			[routes addObject:direction.route];
			
		}

	}
	
	//sort otherDirections by route
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	[routes sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	return (NSArray *)routes;
}

#pragma mark -
#pragma mark FlurryAnalytics

+ (NSDictionary *)dictionaryFromStop:(Stop *)stop {
	
	NSArray *keys = [NSArray arrayWithObjects:@"agencyShortTitle", @"tag", @"title", nil];
	NSArray *objects = [NSArray arrayWithObjects:[[DataHelper agencyFromStop:stop] shortTitle], stop.tag, stop.title, nil];	
	
	return [NSDictionary dictionaryWithObjects:objects forKeys:keys];

}

+ (NSDictionary *)dictionaryFromRoute:(Route *)route {
	
	NSArray *keys = [NSArray arrayWithObjects:@"agencyShortTitle", @"tag", nil];
	NSArray *objects = [NSArray arrayWithObjects:route.agency.shortTitle, route.tag, nil];	
	
	return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	
}


#pragma mark -
#pragma mark Static Maps GEO-TO X-Y code

+ (int)xCoordinateFromLongitude:(CGFloat)lon {
	
	double offset = 268435456;
	double radius = offset / M_PI;
	
	return round(offset + radius * lon * M_PI / 180);

}

+ (int)yCoordinateFromLatitude:(CGFloat)lat {
	
	double offset = 268435456;
	double radius = offset / M_PI;
	
	return round(offset - radius * log((1 + sin(lat * M_PI / 180)) / (1 - sin(lat * M_PI / 180))) / 2);
	
}


@end
