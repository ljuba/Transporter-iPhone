//
// RowDivider.h
// New Image
//
// Created by Ljuba Miljkovic on 4/25/10
// Copyright Like Thought, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kRowDividerWidth;

@interface RowDivider : UIView
{
	NSString *title;
}

@property (copy, nonatomic) NSString *title;

@end
