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

@property (nonatomic, retain) NSString *shortTitle;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *lastUpdate;
@property (nonatomic, retain) NSSet *routes;

@end

@interface Agency (CoreDataGeneratedAccessors)
- (void) addRoutesObject:(Route *)value;
- (void) removeRoutesObject:(Route *)value;
- (void) addRoutes:(NSSet *)value;
- (void) removeRoutes:(NSSet *)value;

@end
