//
//	TripHeaderView.h
//	New Image
//
//	Created by Ljuba Miljkovic on 4/22/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>

extern const CGFloat kTripHeaderViewWidth;
extern const CGFloat kTripHeaderViewHeight;

@interface TripHeaderView : UIView
{
	NSString *startTitle;
	NSString *durationTitle;
}

@property (copy, nonatomic) NSString *startTitle;
@property (copy, nonatomic) NSString *durationTitle;

@end
