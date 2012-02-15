//
//  BartColorsView.h
//  kronos
//
//  Created by Ljuba Miljkovic on 4/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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

- (id)initWithColors:(NSArray *)_colors atPoint:(CGPoint)point;

@property (nonatomic, retain) NSArray *colors;

@property (nonatomic, retain) UIImage *redImage;
@property (nonatomic, retain) UIImage *orangeImage;
@property (nonatomic, retain) UIImage *yellowImage;
@property (nonatomic, retain) UIImage *blueImage;
@property (nonatomic, retain) UIImage *greenImage;

@end
