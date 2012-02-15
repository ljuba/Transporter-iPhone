//
//  Agency.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Line;

@interface Agency :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * shortTitle;
@property (nonatomic, retain) NSSet* routes;

@end


@interface Agency (CoreDataGeneratedAccessors)
- (void)addRoutesObject:(Line *)value;
- (void)removeRoutesObject:(Line *)value;
- (void)addRoutes:(NSSet *)value;
- (void)removeRoutes:(NSSet *)value;

@end

