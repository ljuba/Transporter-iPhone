//
//  Route.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Agency;
@class Direction;

@interface Route :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * shortTitle;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * vehicle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) Agency * agency;
@property (nonatomic, retain) NSSet* direction;

@end


@interface Route (CoreDataGeneratedAccessors)
- (void)addDirectionObject:(Direction *)value;
- (void)removeDirectionObject:(Direction *)value;
- (void)addDirection:(NSSet *)value;
- (void)removeDirection:(NSSet *)value;

@end

