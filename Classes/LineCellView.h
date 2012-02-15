//
//	LineCellView.h
//	New Image
//
//	Created by Ljuba Miljkovic on 4/25/10
//	Copyright Like Thought, LLC. All rights reserved.
//	THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import <UIKit/UIKit.h>
#import "Stop.h"
#import "PredictionLabel.h"
#import "Constants.h"

extern const CGFloat kLineCellViewWidth;
extern const CGFloat kLineCellViewHeight;

@interface LineCellView : UIView
{
	NSString *majorTitle;
	UIColor *textColor;
	
	UIButton *favoriteButton;
	Stop *stop;
	
	BOOL isFavorite;
	
	PredictionLabel *prediction1Label;
	PredictionLabel *prediction2Label;
	PredictionLabel *prediction3Label;
	
	int cellStatus;
	
	UIActivityIndicatorView *spinner;
	UILabel *minuteLabel;
	
	UIFont *font;
	
}

@property (copy, nonatomic) NSString *majorTitle;
@property (retain, nonatomic) UIColor *textColor;
@property (nonatomic, retain) UIButton *favoriteButton;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) UIFont *font;

@property int cellStatus;
@property BOOL isFavorite;

@property (nonatomic, retain) PredictionLabel *prediction1Label;
@property (nonatomic, retain) PredictionLabel *prediction2Label;
@property (nonatomic, retain) PredictionLabel *prediction3Label;
@property (nonatomic, retain) UILabel *minuteLabel;

- (void)setCellStatus:(int)status withArrivals:(NSArray *)arrivals;
- (void)toggleFavorite;
- (void)showMinuteLabel:(NSNotification *)note;
- (void)hideMinuteLabel:(NSNotification *)note;
@end
