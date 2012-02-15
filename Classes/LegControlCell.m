//
//  LegControlCell.m
//  transporter
//
//  Created by Ljuba Miljkovic on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LegControlCell.h"
#import "Constants.h"

@implementation LegControlCell

@synthesize rerouteButton, segmentMapButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
		self.frame = CGRectMake(0, 0, 320, kButtonRowHeight);
		self.contentView.backgroundColor = [UIColor colorWithWhite:0.32 alpha:1.0];
		
		//SETUP BUTTONS
		self.rerouteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rerouteButton.frame = CGRectMake(0, 0, 159, kButtonRowHeight);
		[rerouteButton setImage:[UIImage imageNamed:@"reroute-button-default.png"] forState:UIControlStateNormal];
		[rerouteButton setImage:[UIImage imageNamed:@"reroute-button-selected.png"] forState:UIControlStateHighlighted];
		[self.contentView addSubview:rerouteButton];
		
		self.segmentMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
		segmentMapButton.frame = CGRectMake(160, 0, 160, kButtonRowHeight);
		[segmentMapButton setImage:[UIImage imageNamed:@"segment-map-button-default.png"] forState:UIControlStateNormal];
		[segmentMapButton setImage:[UIImage imageNamed:@"segment-map-button-selected.png"] forState:UIControlStateHighlighted];
		[self.contentView addSubview:segmentMapButton];		
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
