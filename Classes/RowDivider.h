//
// RowDivider.h
// New Image
//
// Created by Ljuba Miljkovic on 4/25/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>

extern const CGFloat kRowDividerWidth;

@interface RowDivider : UIView
{
	NSString *title;
}

@property (copy, nonatomic) NSString *title;

@end
