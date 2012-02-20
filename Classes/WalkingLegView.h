//
// WalkingLegView.h
// New Image
//
// Created by Ljuba Miljkovic on 4/22/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>

extern const CGFloat kWalkingLegViewWidth;
extern const CGFloat kWalkingLegViewHeight;

@interface WalkingLegView : UIView
{
	NSString *time;
	NSString *majorTitle;
	NSString *minorTitle;
	UIImageView *centerImageView;
}

@property (copy, nonatomic) NSString *time;
@property (copy, nonatomic) NSString *majorTitle;
@property (copy, nonatomic) NSString *minorTitle;
@property (nonatomic, retain) UIImageView *centerImageView;

- (void) setPositionInTrip:(int)position;

@end
