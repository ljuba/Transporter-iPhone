//
//  sfMuniDelegate.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransitDelegate.h"
#import "Agency.h"
#import "Route.h"

#define kRowHeight 60

@interface sfMuniDelegate : TransitDelegate {
	
	NSArray *formattedContents;
	
}

@property (nonatomic, retain) NSArray *formattedContents;

- (id)initWithAgency:(Agency *)agency;

@end
