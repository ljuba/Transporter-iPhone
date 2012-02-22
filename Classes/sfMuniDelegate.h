//
// sfMuniDelegate.h
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Agency.h"
#import "Route.h"
#import "TransitDelegate.h"
#import <Foundation/Foundation.h>

#define kRowHeight 60

@interface sfMuniDelegate : TransitDelegate {

	NSArray *formattedContents;

}

@property (nonatomic) NSArray *formattedContents;

- (id) initWithAgency:(Agency *)agency;

@end
