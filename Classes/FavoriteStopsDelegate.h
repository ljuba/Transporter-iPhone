//
// FavoritesStops.h
// kronos
//
// Created by Ljuba Miljkovic on 4/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FavoritesDelegate.h"
#import <Foundation/Foundation.h>

@interface FavoriteStopsDelegate : FavoritesDelegate {

	NSMutableDictionary *predictions;

}

@property (nonatomic, retain) NSMutableDictionary *predictions;

- (void) loadFavoritesFile;
- (void) saveContentsToFavoritesFile;

@end
