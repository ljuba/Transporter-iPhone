//
//  DataHelper.h
//  kronos
//
//  Created by Ljuba Miljkovic on 4/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Agency.h"
#import "Route.h"
#import "Direction.h"
#import "Stop.h"
#import "Destination.h"

#import <CoreLocation/CoreLocation.h>

@interface DataHelper : NSObject {

}

+ (Stop *)bartStopWithName:(NSString *)bartStopTitle;
+ (Agency *)agencyWithShortTitle:(NSString *)agencyShortTitle;
+ (Route *)routeWithTag:(NSString *)routeTag inAgency:(Agency *)agency;
+ (Stop *)stopWithTag:(NSString *)stopTag inDirection:(Direction *)direction;

+ (Agency *)agencyFromStop:(Stop *)stop;
+ (NSArray *)directionTagsThatMatchDirectionName:(NSString *)dirName directionTitle:(NSString *)dirTitle routeTag:(NSString *)routeTag forAgencyWithShortTitle:(NSString *)agencyShortTitle;
+ (NSArray *)directionTagsInRoute:(Route *)route thatMatchDirectionName:(NSString *)dirName directionTitle:(NSString *)dirTitle;

+ (CLLocation *)locationOfStop:(Stop *)stop;
+ (NSMutableArray *)findClosestStopsFromLocation:(CLLocation *)location amongStops:(NSArray *)stops count:(int)number;
+ (NSArray *)uniqueRoutesForStop:(Stop *)stop;
+ (void)saveStopObjectIDInUserDefaults:(Stop *)stop;
+ (void)saveDirectionIDInUserDefaults:(Direction *)direction forKey:(NSString*)key;
+ (Stop *)stopWithTag:(NSString *)stopTag inAgency:(Agency *)agency;
+ (Stop *)stopWithTag:(NSString *)stopTag inAgencyWithShortTitle:(NSString *)agencyShortTitle;

+ (Destination *)destinationForBARTStopTag:(NSString *)stopTag toStopTag:(NSString *)destinationStopTag;

+ (Route *)routeWithTag:(NSString *)routeTag inAgencyWithShortTitle:(NSString *)agencyShortTitle;

+ (int)xCoordinateFromLongitude:(CGFloat)lon;
+ (int)yCoordinateFromLatitude:(CGFloat)lat;

+ (Direction *)directionWithTag:(NSString *)dirTag inRoute:(Route *)route;
+ (NSArray *)bartDirectionsWithTitle:(NSString *)title;

+ (NSDictionary *)dictionaryFromStop:(Stop *)stop;
+ (NSDictionary *)dictionaryFromRoute:(Route *)route;


@end
