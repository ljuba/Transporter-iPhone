//
// BartColorsView.m
// kronos
//
// Created by Ljuba Miljkovic on 4/17/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BartColorsView.h"

@implementation BartColorsView

@synthesize redImage, orangeImage, yellowImage, greenImage, blueImage, colors;

- (id) initWithColors:(NSArray *)_colors atPoint:(CGPoint)point {

	if ( (self = [super init]) ) {

		self.redImage = [UIImage imageNamed:@"bart-red.png"];
		self.orangeImage = [UIImage imageNamed:@"bart-orange.png"];
		self.yellowImage = [UIImage imageNamed:@"bart-yellow.png"];
		self.greenImage = [UIImage imageNamed:@"bart-green.png"];
		self.blueImage = [UIImage imageNamed:@"bart-blue.png"];
        
		self.opaque = NO;

		colors = _colors;

		CGSize size = CGSizeMake(5 * redImage.size.width + 5 * kBartColorSpacer, redImage.size.height);

		self.frame = CGRectMake(point.x, point.y, size.width, size.height);

	}
	return(self);
}

- (void) drawRect:(CGRect)rect {

	int x = 0;
	int y = 0;

	for (NSString *color in colors) {

		x = [colors indexOfObject:color] * (redImage.size.width + kBartColorSpacer);

		CGPoint point = CGPointMake(x, y);

		if ([color isEqual:@"red"]) [redImage drawAtPoint:point];
		else if ([color isEqual:@"orange"]) [orangeImage drawAtPoint:point];
		else if ([color isEqual:@"yellow"]) [yellowImage drawAtPoint:point];
		else if ([color isEqual:@"green"]) [greenImage drawAtPoint:point];
		else if ([color isEqual:@"blue"]) [blueImage drawAtPoint:point];
	}
}


@end
