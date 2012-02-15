//
//	TransitLegView.h
//	New Image
//
//	Created by Ljuba Miljkovic on 4/22/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>
#import "Route.h"

extern const CGFloat kTransitLegViewWidth;
extern const CGFloat kTransitLegViewHeight;

@interface TransitLegView : UIView
{
	NSString *startTime;
	NSString *endTime;
	NSString *startStopTitle;
	NSString *endStopTitle;
	NSString *transferText;
	NSString *majorTitle;
	NSString *minorTitle;
	
	UILabel *routeTagLabel;
	UIImageView *routeBackground;
	UIImageView *bartColor;
}

@property (nonatomic, retain) UILabel *routeTagLabel;
@property (nonatomic, retain) UIImageView *routeBackground;
@property (nonatomic, retain) UIImageView *bartColor;

@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;
@property (copy, nonatomic) NSString *startStopTitle;
@property (copy, nonatomic) NSString *endStopTitle;
@property (copy, nonatomic) NSString *transferText;
@property (copy, nonatomic) NSString *majorTitle;
@property (copy, nonatomic) NSString *minorTitle;

- (void)setRoute:(Route *)route;

@end
