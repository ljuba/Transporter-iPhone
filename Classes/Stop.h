//
//  Stop.h
//  transporter
//
//  Created by Ljuba Miljkovic on 10/22/10.
//  Copyright 2010 Adaptive Path. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Agency;
@class Direction;

@interface Stop :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) Agency * agency;
@property (nonatomic, retain) Stop * oppositeStop;
@property (nonatomic, retain) NSSet* directions;

@end


@interface Stop (CoreDataGeneratedAccessors)
- (void)addDirectionsObject:(Direction *)value;
- (void)removeDirectionsObject:(Direction *)value;
- (void)addDirections:(NSSet *)value;
- (void)removeDirections:(NSSet *)value;

@end

