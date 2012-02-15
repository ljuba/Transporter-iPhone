//
//  Stop.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Direction;

@interface Stop :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * group;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSSet* directions;

@end


@interface Stop (CoreDataGeneratedAccessors)
- (void)addDirectionsObject:(Direction *)value;
- (void)removeDirectionsObject:(Direction *)value;
- (void)addDirections:(NSSet *)value;
- (void)removeDirections:(NSSet *)value;

@end

