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

@property (nonatomic) BartColorsView *colorsView;

@property (nonatomic) UIColor *lightColor;
@property (nonatomic) UIColor *darkColor;

@property (nonatomic) UIImage *backgroundImage;
@property (nonatomic) NSString *majorTitle;
@property (nonatomic) NSString *minorTitle;
@property (nonatomic) NSArray *arrivals;

@property (nonatomic) PredictionLabel *prediction1Label;
@property (nonatomic) PredictionLabel *prediction2Label;
@property (nonatomic) PredictionLabel *prediction3Label;

@property (nonatomic) UIActivityIndicatorView *spinner;

- (id) initWithLineItem:(NSDictionary *)lineItem withColors:(NSArray *)colors inRange:(NSRange)range;

@end
