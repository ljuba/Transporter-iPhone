//
// CustomButton.h
// transporter
//
// Created by Ljuba Miljkovic on 5/8/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton {

	UIImage *image;

}

- (id) initWithColor:(NSString *)color;
@property (nonatomic, retain) UIImage *image;

@end
