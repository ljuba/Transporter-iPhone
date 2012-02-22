//
// Direction.h
// transporter
//
// Created by Ljuba Miljkovic on 6/13/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Route;
@class Stop;

@interface Direction :  NSManagedObject
{}

@property (nonatomic) NSString *title;
@property (nonatomic) NSNumber *show;
@property (nonatomic) id stopOrder;
@property (nonatomic) NSString *tag;
@property (nonatomic) NSString *name;
@property (nonatomic) NSSet *stops;
@property (nonatomic) Route *route;

@end

@interface Direction (CoreDataGeneratedAccessors)
- (void) addStopsObject:(Stop *)value;
- (void) removeStopsObject:(Stop *)value;
- (void) addStops:(NSSet *)value;
- (void) removeStops:(NSSet *)value;

@end
