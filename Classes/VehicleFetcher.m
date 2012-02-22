//
// VehicleFetcher.m
// transporter
//
// Created by Ljuba Miljkovic on 5/8/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "VehicleFetcher.h"
#import "kronosAppDelegate.h"

@implementation VehicleFetcher

- (void) fetchVehiclesForDirection:(Direction *)direction {

	@autoreleasepool {

		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];

		Route *route = direction.route;
		Agency *agency = route.agency;

		NSString *urlString = [NSString stringWithFormat:@"http://www.nextbus.com/s/COM.NextBus.Servlets.XMLFeed?command=vehicleLocations&a=%@&t=0&r=%@", agency.shortTitle, route.tag];

	NSLog(@"%@", urlString); /* DEBUG LOG */

		NSURL *url = [[NSURL alloc] initWithString:urlString];

		CXMLDocument *vehiclesDocument = [[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil];

		// stores the vehicle objects that are created from the XML data
		NSMutableArray *vehicles = [[NSMutableArray alloc] init];

		// find all vehicle elements
		NSArray *vehicleNodes = [vehiclesDocument nodesForXPath:@"//vehicle" error:nil];

		for (CXMLElement *vehicleElement in vehicleNodes) {

			// iterate through all the attributes (whatever they may be) for each vehicle node and populate two arrays: attribute names, attribute values
			NSMutableArray *attributeNames = [NSMutableArray array];
			NSMutableArray *attributeValues = [NSMutableArray array];

			for (CXMLElement *attributeElement in [vehicleElement attributes]) {

				[attributeNames addObject:[attributeElement name]];
				[attributeValues addObject:[attributeElement stringValue]];

			}
			NSDictionary *vehicle = [NSDictionary dictionaryWithObjects:attributeValues forKeys:attributeNames];

			[vehicles addObject:vehicle];

		}
		// filter the vehicles for the ones that match the direction we want

		NSMutableArray *filteredvehicles = [[NSMutableArray alloc] init];

		for (NSDictionary *vehicle in vehicles)

			if ([[vehicle objectForKey:@"predictable"] isEqualToString:@"true"]) {

				NSString *vehicleDirTag = [vehicle objectForKey:@"dirTag"];
				NSString *vehicleRouteTag = [vehicle objectForKey:@"routeTag"];

				// basic dummy check for route match
				if ([vehicleRouteTag isEqualToString:route.tag]) {

					Direction *vehicleDirection = [DataHelper directionWithTag:vehicleDirTag inRoute:route];

					// check that direction name (e.g. outbound) and title (to rockridge bart) matches between vehicle direction and requested direction
					if ([vehicleDirection.name isEqualToString:direction.name]&&[vehicleDirection.title isEqualToString:direction.title]) [filteredvehicles addObject:vehicle];
				}
			}
		// find the topmost view controller and see if it responds to "setupTripOverview:"
		// if so, send it the current predictions
		UINavigationController *navController = (UINavigationController *)appDelegate.tabBarController.selectedViewController;

		if ([navController.topViewController respondsToSelector:@selector(didReceiveVehicles:)]) [navController.topViewController performSelectorOnMainThread:@selector(didReceiveVehicles:) withObject:filteredvehicles waitUntilDone:YES];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	}

}

@end
