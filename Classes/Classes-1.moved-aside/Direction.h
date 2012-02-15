//
//  Direction.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Line;
@class Stop;

@interface Direction :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * show;
@property (nonatomic, retain) id stopOrder;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSSet* stops;
@property (nonatomic, retain) Line * route;

@end


@interface Direction (CoreDataGeneratedAccessors)
- (void)addStopsObject:(Stop *)value;
- (void)removeStopsObject:(Stop *)value;
- (void)addStops:(NSSet *)value;
- (void)removeStops:(NSSet *)value;

@end

