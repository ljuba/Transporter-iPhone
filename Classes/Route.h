//
// Route.h
// transporter
//
// Created by Ljuba Miljkovic on 6/13/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Agency;
@class Direction;

@interface Route :  NSManagedObject
{}

@property (nonatomic) NSString *color;
@property (nonatomic) NSNumber *sortOrder;
@property (nonatomic) NSString *vehicle;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *tag;
@property (nonatomic) Agency *agency;
@property (nonatomic) NSSet *directions;

@end

@interface Route (CoreDataGeneratedAccessors)
- (void) addDirectionsObject:(Direction *)value;
- (void) removeDirectionsObject:(Direction *)value;
- (void) addDirections:(NSSet *)value;
- (void) removeDirections:(NSSet *)value;

@end
