//
//  FavoritesManager.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stop.h"
#import "Direction.h"
#import "Route.h"
#import "Agency.h"

@interface FavoritesManager : NSObject {

}


+ (BOOL)addStopToFavorites:(Stop *)stop forLine:(id)d;
+ (BOOL)removeStopFromFavorites:(Stop *)stop forLine:(id)d;
+ (NSArray *)getFavorites;
+ (BOOL)isFavoriteStop:(Stop *)stop forLine:(id)line;
+ (void)saveFavorites:(NSArray *)contents;

+ (NSDictionary *)sortLinesInStopItem:(NSDictionary *)stopItem;
+ (void)checkExistanceOfFavorites;

@end
