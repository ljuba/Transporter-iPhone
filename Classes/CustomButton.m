//
// CustomButton.m
// transporter
//
// Created by Ljuba Miljkovic on 5/8/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

@synthesize image;

- (id) initWithColor:(NSString *)color {
	if (self = [super init]) {

		self.frame = CGRectMake(0, 0, 54, 30);

		// Center the text vertically and horizontally
		self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

		if ([color isEqualToString:@"blue"]) image = [UIImage imageNamed:@"blue-button.png"];
		else image = [UIImage imageNamed:@"green-button.png"];
		// Make a stretchable image from the original image
		UIImage *stretchImage = [image stretchableImageWithLeftCapWidth:15.0 topCapHeight:0.0];

		// Set the background to the stretchable image
		[self setBackgroundImage:stretchImage forState:UIControlStateNormal];

		// Make the background color clear
		self.backgroundColor = [UIColor clearColor];

		// Set the font properties
		[self setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateDisabled];
		[self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateDisabled];

		[self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];
		self.titleLabel.shadowOffset = CGSizeMake(0, -0.75);
		self.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	}
	return(self);
}


@end
