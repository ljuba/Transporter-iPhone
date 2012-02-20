//
// RoutesCell.m
// kronos
//
// Created by Ljuba Miljkovic on 3/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RoutesCell.h"

@implementation RoutesCell

@synthesize buttons;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])	self.buttons = [[[NSMutableArray alloc] init] autorelease];
	return(self);
}

- (void) dealloc {

	[buttons release];

	[super dealloc];

}

@end
