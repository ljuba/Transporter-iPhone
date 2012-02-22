//
// BartColorsView.h
// kronos
//
// Created by Ljuba Miljkovic on 4/17/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBartColorSpacer 3

@interface BartColorsView : UIView {

	NSArray *colors;

	UIImage *redImage;
	UIImage *orangeImage;
	UIImage *yellowImage;
	UIImage *blueImage;
	UIImage *greenImage;

}

- (id) initWithColors:(NSArray *)_colors atPoint:(CGPoint)point;

@property (nonatomic) NSArray *colors;

@property (nonatomic) UIImage *redImage;
@property (nonatomic) UIImage *orangeImage;
@property (nonatomic) UIImage *yellowImage;
@property (nonatomic) UIImage *blueImage;
@property (nonatomic) UIImage *greenImage;

@end
