//
//  acTransitDelegate.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Agency.h"
#import "Route.h"
#import "TransitDelegate.h"

#define kRowHeight 60

@interface acTransitDelegate : TransitDelegate {

	NSArray *formattedContents;
	
}

@property (nonatomic, retain) NSArray *formattedContents;


- (void)tapRoute:(UIButton *)sender;
- (id)initWithAgency:(Agency *)agency;

@end
