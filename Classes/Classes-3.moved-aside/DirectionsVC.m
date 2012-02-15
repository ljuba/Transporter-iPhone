//
//  DirectionsVC.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DirectionsVC.h"


@implementation DirectionsVC

@synthesize directions;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
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
