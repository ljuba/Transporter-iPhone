//
//  TransitLegCell.m
//  kronos
//
//  Created by Ljuba Miljkovic on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TransitLegCell.h"


@implementation TransitLegCell

@synthesize transitLegView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame {
    
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    
		self.clipsToBounds = YES;
		
		// Create a Transit Lege view and add it to the cell's content view
		transitLegView = [[TransitLegView alloc] initWithFrame:frame];
		[self.contentView addSubview:transitLegView];
    
	}
	return self;
}






- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	
	[transitLegView release];
	
    [super dealloc];
}


@end
