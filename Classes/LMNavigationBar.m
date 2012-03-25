//
//  LMNavigationBar.m
//  transporter
//
//  Created by Ljuba Miljkovic on 3/24/12.
//  Copyright (c) 2012 Ljuba Miljkovic. All rights reserved.
//

#import "LMNavigationBar.h"

@implementation LMNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	UIImage *image = [UIImage imageNamed:@"seg-topbar.png"];
	[image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
