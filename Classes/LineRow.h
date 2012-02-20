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

@property (nonatomic, retain) BartColorsView *colorsView;

@property (nonatomic, retain) UIColor *lightColor;
@property (nonatomic, retain) UIColor *darkColor;

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) NSString *majorTitle;
@property (nonatomic, retain) NSString *minorTitle;
@property (nonatomic, retain) NSArray *arrivals;

@property (nonatomic, retain) PredictionLabel *prediction1Label;
@property (nonatomic, retain) PredictionLabel *prediction2Label;
@property (nonatomic, retain) PredictionLabel *prediction3Label;

@property (nonatomic, retain) UIActivityIndicatorView *spinner;

- (id) initWithLineItem:(NSDictionary *)lineItem withColors:(NSArray *)colors inRange:(NSRange)range;

@end
