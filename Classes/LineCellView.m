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
@synthesize prediction1Label, prediction2Label, prediction3Label, minuteLabel;

- (id) init
{
	CGRect frame = CGRectMake(0, 0, kLineCellViewWidth, kLineCellViewHeight);

	self = [super initWithFrame:frame];

	if (self) {
		majorTitle = @"60 Outbound";
		textColor = [UIColor colorWithRed:0.147 green:0.147 blue:0.147 alpha:1.0];
		[self setOpaque:NO];

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
		prediction1Label.text = @"";
		prediction1Label.isFirstArrival = YES;

		prediction2Label = [[PredictionLabel alloc] initWithFrame:CGRectMake(294, 2, 27, 27)];
		prediction2Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction2Label.textColor = textColor;
		prediction2Label.font = [UIFont boldSystemFontOfSize:14];
		prediction2Label.textAlignment = UITextAlignmentCenter;
		prediction2Label.text = @"";
		prediction2Label.isFirstArrival = NO;

		prediction3Label = [[PredictionLabel alloc] initWithFrame:CGRectMake(294, 32, 27, 27)];
		prediction3Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction3Label.textColor = textColor;
		prediction3Label.font = [UIFont boldSystemFontOfSize:14];
		prediction3Label.textAlignment = UITextAlignmentCenter;
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
	CGFloat alignStroke;
	CGFloat resolution;
	CGMutablePathRef path;
	CGRect drawRect;
	CGGradientRef gradient;
	NSMutableArray *colors;
	UIColor *color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPoint point;
	CGPoint point2;
	CGAffineTransform transform;
	CGMutablePathRef tempPath;
	CGRect pathBounds;
	CGFloat stroke;
	CGFloat locations[2];
	resolution = 0.5f * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM( context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height) );

	// background

	alignStroke = 0.0f;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0f, 1.0f, 320.0f, 59.0f);
	drawRect.origin.x = (roundf(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (roundf(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.624f green:0.619f blue:0.642f alpha:1.0f];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0f;
	color = [UIColor colorWithRed:0.783f green:0.783f blue:0.793f alpha:1.0f];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0f;
	gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(1.571f);
	tempPath = CGPathCreateMutable();
	CGPathAddPath(tempPath, &transform, path);
	pathBounds = CGPathGetBoundingBox(tempPath);
	point = pathBounds.origin;
	point2 = CGPointMake( CGRectGetMaxX(pathBounds), CGRectGetMinY(pathBounds) );
	transform = CGAffineTransformInvert(transform);
	point = CGPointApplyAffineTransform(point, transform);
	point2 = CGPointApplyAffineTransform(point2, transform);
	CGPathRelease(tempPath);
	CGContextDrawLinearGradient( context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation) );
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	CGPathRelease(path);

	// Layer 5

	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(0.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(320.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.873f green:0.873f blue:0.878f alpha:1.0f];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Layer 3

	CGContextSetShouldAntialias(context, NO);
	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(295.0f, 60.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(295.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.27f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Layer 2

	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(239.0f, 60.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(239.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.27f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// divider lines

	CGContextSetShouldAntialias(context, YES);
	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(238.0f, 61.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(238.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(320.0f, 30.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(294.5f, 30.5f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.551f green:0.55f blue:0.564f alpha:1.0f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Layer 1

	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(294.0f, 61.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(294.0f, 0.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Layer 4

	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(320.0f, 31.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(295.0f, 31.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.779f green:0.778f blue:0.788f alpha:1.0f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Layer 6

	stroke = 1.0f;
	stroke *= resolution;

	if (stroke < 1.0f) stroke = ceilf(stroke);
	else stroke = roundf(stroke);
	stroke /= resolution;
	alignStroke = fmodf(0.5f * stroke * resolution, 1.0f);
	path = CGPathCreateMutable();
	point = CGPointMake(0.0f, 60.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(320.0f, 60.0f);
	point.x = (roundf(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (roundf(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.483f green:0.479f blue:0.496f alpha:1.0f];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Layer 7

	drawRect = CGRectMake(36.0f, 6.0f, 198.0f, 29.0f);
	drawRect.origin.x = roundf(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = roundf(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = roundf(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = roundf(resolution * drawRect.size.height) / resolution;
	[textColor set];
	[majorTitle drawInRect:drawRect withFont:font];
    
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);

}
@end
