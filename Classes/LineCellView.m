//
// LineCellView.m
// New Image
//
// Created by Ljuba Miljkovic on 4/25/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "LineCellView.h"

const CGFloat kLineCellViewWidth = 320.0;
const CGFloat kLineCellViewHeight = 61.0;

@implementation LineCellView

@synthesize majorTitle, textColor, favoriteButton, stop, isFavorite, spinner, font, cellStatus;
@synthesize prediction1Label, prediction2Label, prediction3Label, minuteLabel, backgroundImage;

- (id) init
{
	CGRect frame = CGRectMake(0, 0, kLineCellViewWidth, kLineCellViewHeight);

	self = [super initWithFrame:frame];

	if (self) {
		majorTitle = @"60 Outbound";
		textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
		[self setOpaque:NO];

        //SET BACKGROUND IMAGE
        self.backgroundImage = [UIImage imageNamed:@"line-background.png"]; //drawn in drawRect
        
		// ADD THE FAVORITES BUTTON
		favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(-1, 3, 39, 55)];
		[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateNormal];
		[favoriteButton setImage:[UIImage imageNamed:@"star-unselected.png"] forState:UIControlStateHighlighted];

		[favoriteButton addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventTouchUpInside];
		favoriteButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		favoriteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[self addSubview:favoriteButton];

		// ADD PREDICTION LABELS
		prediction1Label = [[PredictionLabel alloc] initWithFrame:CGRectMake(240, 3, 53, 47)];
		prediction1Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction1Label.textColor = textColor;
		prediction1Label.font = [UIFont boldSystemFontOfSize:30];
		prediction1Label.textAlignment = UITextAlignmentCenter;
        prediction1Label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        prediction1Label.shadowOffset = CGSizeMake(0, 1);
		prediction1Label.text = @"";
		prediction1Label.isFirstArrival = YES;

		prediction2Label = [[PredictionLabel alloc] initWithFrame:CGRectMake(294, 2, 27, 27)];
		prediction2Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction2Label.textColor = textColor;
		prediction2Label.font = [UIFont boldSystemFontOfSize:14];
		prediction2Label.textAlignment = UITextAlignmentCenter;
        prediction2Label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        prediction2Label.shadowOffset = CGSizeMake(0, 1);
		prediction2Label.text = @"";
		prediction2Label.isFirstArrival = NO;

		prediction3Label = [[PredictionLabel alloc] initWithFrame:CGRectMake(294, 32, 27, 27)];
		prediction3Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction3Label.textColor = textColor;
		prediction3Label.font = [UIFont boldSystemFontOfSize:14];
		prediction3Label.textAlignment = UITextAlignmentCenter;
        prediction3Label.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        prediction3Label.shadowOffset = CGSizeMake(0, 1);
		prediction3Label.text = @"";
		prediction3Label.isFirstArrival = NO;

		[self addSubview:prediction1Label];
		[self addSubview:prediction2Label];
		[self addSubview:prediction3Label];

		// ADD SPINNER
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(256, 19, 20, 20)];
		spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		spinner.hidesWhenStopped = YES;
		[spinner stopAnimating];
		[self addSubview:spinner];

		// ADD MINUTE LABEL
		minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(252, 41, 31, 14)];
		minuteLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		minuteLabel.textColor = textColor;
		minuteLabel.font = [UIFont systemFontOfSize:11];
		minuteLabel.textAlignment = UITextAlignmentCenter;
		minuteLabel.text = @"min";
		[self addSubview:minuteLabel];

		// SETUP NOTIFICATIONS
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(hideMinuteLabel:) name:@"imminentArrivalYES" object:nil];
		[nc addObserver:self selector:@selector(showMinuteLabel:) name:@"imminentArrivalNO" object:nil];

	}
	return(self);
}

- (void) hideMinuteLabel:(NSNotification *)note {

	if (note.object == self) {

		NSLog(@"HIDE MINUTE LABEL %@", note.object); /* DEBUG LOG */
		minuteLabel.hidden = YES;
	}
}

- (void) showMinuteLabel:(NSNotification *)note {

	if (note.object == self)
		// NSLog(@"%@", note.object); /* DEBUG LOG */
		minuteLabel.hidden = NO;
}

- (void) setFont:(UIFont *)_font {

	font = _font;
	[self setNeedsDisplay];

}

- (void) setCellStatus:(int)status withArrivals:(NSArray *)arrivals {

	// don't use the view controller cell status if you know there are arrivals
	if ( ([arrivals count] == 0)||(arrivals == nil) ) cellStatus = status;
	else cellStatus = kCellStatusDefault;

	if (cellStatus == kCellStatusSpinner) {
		spinner.hidden = NO;
		minuteLabel.hidden = YES;
		textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
		prediction1Label.alpha = 1.0;
		[prediction1Label clear];
		[prediction2Label clear];
		[prediction3Label clear];
		[spinner startAnimating];
		[self setNeedsDisplay];
		return;
	} else if (cellStatus == kCellStatusInternetFail) {
		[spinner stopAnimating];
		prediction1Label.text = nil;
		minuteLabel.hidden = YES;
		return;

	} else if (cellStatus == kCellStatusPredictionFail) {
		minuteLabel.hidden = YES;
		[spinner startAnimating];
		return;
	} else if (cellStatus == kCellStatusDefault) {
		[spinner stopAnimating];

		int numberOfArrivals = [arrivals count];

		switch (numberOfArrivals) {
		case 0:
			prediction1Label.text = @"—";
			prediction1Label.alpha = 0.6;
			prediction2Label.text = @"";
			prediction3Label.text = @"";
			textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:0.6];
			minuteLabel.hidden = YES;
			break;
		case 1:
			textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
			prediction2Label.text = @"-";
			prediction3Label.text = @"-";
			prediction1Label.alpha = 1.0;
			break;
		case 2:
			prediction3Label.text = @"-";
			textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
			prediction1Label.alpha = 1.0;
			break;
		default:
			textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
			prediction1Label.alpha = 1.0;
			break;
		}
		[self setNeedsDisplay];
		return;

	}
}

// overridden in subclasses
- (void) toggleFavorite {}

- (void) dealloc
{

	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];

}

- (void) setMajorTitle:(NSString *)value
{
	if ([majorTitle isEqualToString:value])	return;
	majorTitle = [value copy];
	[self setNeedsDisplay];
}

- (void) setTextColor:(UIColor *)value
{
	if ([textColor isEqual:value]) return;
	textColor = value;
	[self setNeedsDisplay];
}

- (CGSize) sizeThatFits:(CGSize)size
{
	return( CGSizeMake(kLineCellViewWidth, kLineCellViewHeight) );
}

- (void) drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0, 0.0, kLineCellViewWidth, kLineCellViewHeight);
	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat resolution;
	CGRect drawRect;
    UIColor *color;

	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM( context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height) );

	// background
	[backgroundImage drawInRect:dirtyRect];

    // Setup for Shadow Effect
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0.0f * resolution, 1.0f * resolution), 0.0f * resolution, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
    
    //major title
	drawRect = CGRectMake(36.0f, 6.0f, 198.0f, 29.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[textColor set];
	[majorTitle drawInRect:drawRect withFont:font];
    
    // End Shadow Effect
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
    
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);

}
@end
