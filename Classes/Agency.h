//
// Agency.h
// transporter
//
// Created by Ljuba Miljkovic on 6/13/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Route;

@interface Agency :  NSManagedObject
{}

@property (nonatomic) NSString *shortTitle;
@property (nonatomic) NSString *title;
@property (nonatomic) NSNumber *lastUpdate;
@property (nonatomic) NSSet *routes;

@end

@interface Agency (CoreDataGeneratedAccessors)
- (void) addRoutesObject:(Route *)value;
- (void) removeRoutesObject:(Route *)value;
- (void) addRoutes:(NSSet *)value;
- (void) removeRoutes:(NSSet *)value;

@end
