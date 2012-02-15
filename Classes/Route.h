//
//  Route.h
//  transporter
//
//  Created by Ljuba Miljkovic on 6/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Agency;
@class Direction;

@interface Route :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * vehicle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) Agency * agency;
@property (nonatomic, retain) NSSet* directions;

@end


@interface Route (CoreDataGeneratedAccessors)
- (void)addDirectionsObject:(Direction *)value;
- (void)removeDirectionsObject:(Direction *)value;
- (void)addDirections:(NSSet *)value;
- (void)removeDirections:(NSSet *)value;

@end

