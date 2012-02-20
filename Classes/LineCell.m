//
// LineCell.m
// transporter
//
// Created by Ljuba Miljkovic on 4/25/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LineCell.h"

@implementation LineCell

@synthesize lineCellView;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	if ( (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) ) {}
	return(self);
}

- (void) dealloc {
	[super dealloc];
}

@end
