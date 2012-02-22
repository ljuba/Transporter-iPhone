//
// Stop.h
// transporter
//
// Created by Ljuba Miljkovic on 10/22/10.
// Copyright 2010 Adaptive Path. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Agency;
@class Direction;

@interface Stop :  NSManagedObject
{}

@property (nonatomic) NSString *title;
@property (nonatomic) NSNumber *lon;
@property (nonatomic) NSString *tag;
@property (nonatomic) NSString *group;
@property (nonatomic) NSNumber *lat;
@property (nonatomic) Agency *agency;
@property (nonatomic) Stop *oppositeStop;
@property (nonatomic) NSSet *directions;

@end

@interface Stop (CoreDataGeneratedAccessors)
- (void) addDirectionsObject:(Direction *)value;
- (void) removeDirectionsObject:(Direction *)value;
- (void) addDirections:(NSSet *)value;
- (void) removeDirections:(NSSet *)value;

@end
