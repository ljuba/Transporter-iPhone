//
// LineRow.h
// kronos
//
// Created by Ljuba Miljkovic on 4/18/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BartColorsView.h"
#import "PredictionLabel.h"
#import <UIKit/UIKit.h>

@interface LineRow : UIView {

	BOOL isBARTRow;
	UIImage *backgroundImage;

	NSString *majorTitle;
	NSString *minorTitle;

	NSArray *arrivals;

	PredictionLabel *prediction1Label;
	PredictionLabel *prediction2Label;
	PredictionLabel *prediction3Label;

	int rowHeight;

	int cellStatus;

	UIActivityIndicatorView *spinner;

	UIColor *lightColor;
	UIColor *darkColor;

	BartColorsView *colorsView;

}

@property BOOL isBARTRow;
@property int rowHeight;
@property int cellStatus;

@property (nonatomic, strong) BartColorsView *colorsView;

@property (nonatomic, strong) UIColor *lightColor;
@property (nonatomic, strong) UIColor *darkColor;

@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) NSString *majorTitle;
@property (nonatomic, strong) NSString *minorTitle;
@property (nonatomic, strong) NSArray *arrivals;

@property (nonatomic, strong) PredictionLabel *prediction1Label;
@property (nonatomic, strong) PredictionLabel *prediction2Label;
@property (nonatomic, strong) PredictionLabel *prediction3Label;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

- (id) initWithLineItem:(NSDictionary *)lineItem withColors:(NSArray *)colors inRange:(NSRange)range;

@end
