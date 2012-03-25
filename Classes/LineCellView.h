//
// LineCellView.h
// New Image
//
// Created by Ljuba Miljkovic on 4/25/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "Constants.h"
#import "PredictionLabel.h"
#import "Stop.h"
#import <UIKit/UIKit.h>

extern const CGFloat kLineCellViewWidth;
extern const CGFloat kLineCellViewHeight;

@interface LineCellView : UIView
{
	UIButton *favoriteButton;
	Stop *stop;

	BOOL isFavorite;

	PredictionLabel *prediction1Label;
	PredictionLabel *prediction2Label;
	PredictionLabel *prediction3Label;

	int cellStatus;
}

@property (copy, nonatomic) NSString *majorTitle;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) Stop *stop;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIImage *backgroundImage;

@property int cellStatus;
@property BOOL isFavorite;

@property (nonatomic, strong) PredictionLabel *prediction1Label;
@property (nonatomic, strong) PredictionLabel *prediction2Label;
@property (nonatomic, strong) PredictionLabel *prediction3Label;
@property (nonatomic, strong) UILabel *minuteLabel;

- (void) setCellStatus:(int)status withArrivals:(NSArray *)arrivals;
- (void) toggleFavorite;
- (void) showMinuteLabel:(NSNotification *)note;
- (void) hideMinuteLabel:(NSNotification *)note;
@end
