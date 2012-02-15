//
//  Update.m
//  transporter
//
//  Created by ben bloch on 9/8/10.
//  Copyright 2010 Ljuba Miljkovic. All rights reserved.
//

#import "Update.h"


@implementation Update

@synthesize version;
@synthesize updateTime;
@synthesize dataURL;
@synthesize imagesURL;

- (id)init {
	if (!(self = [super init]))
		return nil;
	
	return self;
}


- (void) dealloc
{	
	[updateTime release];
	[dataURL release];
	[imagesURL release];
	[super dealloc];
}


@end
