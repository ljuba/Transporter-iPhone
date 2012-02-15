//
//  Direction.h
//  transporter
//
//  Created by Ljuba Miljkovic on 6/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Route;
@class Stop;

@interface Direction :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * show;
@property (nonatomic, retain) id stopOrder;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* stops;
@property (nonatomic, retain) Route * route;

@end


@interface Direction (CoreDataGeneratedAccessors)
- (void)addStopsObject:(Stop *)value;
- (void)removeStopsObject:(Stop *)value;
- (void)addStops:(NSSet *)value;
- (void)removeStops:(NSSet *)value;

@end

