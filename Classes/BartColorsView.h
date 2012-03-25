//
// BartColorsView.h
// kronos
//
// Created by Ljuba Miljkovic on 4/17/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBartColorSpacer 3

@interface BartColorsView : UIView 

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) UIImage *redImage;
@property (nonatomic, strong) UIImage *orangeImage;
@property (nonatomic, strong) UIImage *yellowImage;
@property (nonatomic, strong) UIImage *blueImage;
@property (nonatomic, strong) UIImage *greenImage;

- (id) initWithColors:(NSArray *)_colors atPoint:(CGPoint)point;


@end
