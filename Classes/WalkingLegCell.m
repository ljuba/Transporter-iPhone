//
//  WalkingLegCell.m
//  kronos
//
//  Created by Ljuba Miljkovic on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WalkingLegCell.h"


@implementation WalkingLegCell

@synthesize walkingLegView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
		walkingLegView = [[WalkingLegView alloc] initWithFrame:frame];
		[self.contentView addSubview:walkingLegView];
		[walkingLegView release];
		
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
