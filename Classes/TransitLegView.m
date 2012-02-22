//
// TransitLegView.m
// New Image
//
// Created by Ljuba Miljkovic on 4/22/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "Agency.h"
#import "TransitLegView.h"

const CGFloat kTransitLegViewWidth = 320.0;
const CGFloat kTransitLegViewHeight = 154.0;

@implementation TransitLegView

@synthesize routeBackground, routeTagLabel, bartColor;

@synthesize startTime;
@synthesize endTime;
@synthesize startStopTitle;
@synthesize endStopTitle;
@synthesize transferText;
@synthesize majorTitle;
@synthesize minorTitle;

- (void) setRoute:(Route *)route {

	NSString *agencyShortTitle = route.agency.shortTitle;

	// SETUP THE ROUTE BACKGROUND IMAGE AND TAG
	if ([agencyShortTitle isEqualToString:@"actransit"]) {

		routeBackground.image = [UIImage imageNamed:@"route-tag-background-actransit.png"];
		routeTagLabel.text = route.tag;
		bartColor.hidden = YES;
	} else if ([agencyShortTitle isEqualToString:@"sf-muni"]) {

		routeBackground.image = [UIImage imageNamed:@"route-tag-background-sfmuni.png"];
		routeTagLabel.text = route.tag;
		bartColor.hidden = YES;

	} else if ([agencyShortTitle isEqualToString:@"bart"]) {

		routeBackground.image = [UIImage imageNamed:@"route-tag-background-bart-blue.png"];
		routeTagLabel.text = @"ba";

		bartColor.hidden = NO;

		if ([route.tag isEqualToString:@"blue"]) bartColor.image = [UIImage imageNamed:@"bart-blue.png"];
		else if ([route.tag isEqualToString:@"green"]) bartColor.image = [UIImage imageNamed:@"bart-green.png"];
		else if ([route.tag isEqualToString:@"orange"])	bartColor.image = [UIImage imageNamed:@"bart-orange.png"];
		else if ([route.tag isEqualToString:@"red"]) bartColor.image = [UIImage imageNamed:@"bart-red.png"];
		else if ([route.tag isEqualToString:@"yellow"])	bartColor.image = [UIImage imageNamed:@"bart-yellow.png"];
	}
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {

		// ROUTE TAG BACKGROUND
		routeBackground = [[UIImageView alloc] initWithFrame:CGRectMake(4, 31, 69, 34)];
		[self addSubview:routeBackground];

		// ROUTE TAG LABEL
		routeTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(21, 36, 50, 23)];
		routeTagLabel.font = [UIFont boldSystemFontOfSize:18];
		routeTagLabel.textColor = [UIColor whiteColor];
		routeTagLabel.textAlignment = UITextAlignmentCenter;
		routeTagLabel.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		routeTagLabel.shadowOffset = CGSizeMake(-1.0, -1.0);
		routeTagLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		routeTagLabel.adjustsFontSizeToFitWidth = YES;
		[self addSubview:routeTagLabel];

		// BART COLORS
		bartColor = [[UIImageView alloc] initWithFrame:CGRectMake(80, 52, 14, 13)];
		bartColor.hidden = YES;
		[self addSubview:bartColor];

		startTime = @"9:10 pm";
		endTime = @"10:42 pm";
		startStopTitle = @"Start stop";
		endStopTitle = @"End stop";
		transferText = @"timed transfer";
		majorTitle = @"Outbound";
		minorTitle = @"Broadway and Blanding";
		[self setOpaque:NO];
	}
	return(self);
}


- (void) setStartTime:(NSString *)value
{
	if ([startTime isEqualToString:value]) return;
	startTime = [value copy];
	[self setNeedsDisplay];
}

- (void) setEndTime:(NSString *)value
{
	if ([endTime isEqualToString:value]) return;
	endTime = [value copy];
	[self setNeedsDisplay];
}

- (void) setStartStopTitle:(NSString *)value
{
	if ([startStopTitle isEqualToString:value]) return;
	startStopTitle = [value copy];
	[self setNeedsDisplay];
}

- (void) setEndStopTitle:(NSString *)value
{
	if ([endStopTitle isEqualToString:value]) return;
	endStopTitle = [value copy];
	[self setNeedsDisplay];
}

- (void) setTransferText:(NSString *)value
{
	if ([transferText isEqualToString:value]) return;
	transferText = [value copy];
	[self setNeedsDisplay];
}

- (void) setMajorTitle:(NSString *)value
{
	if ([majorTitle isEqualToString:value])	return;
	majorTitle = [value copy];
	[self setNeedsDisplay];
}

- (void) setMinorTitle:(NSString *)value
{
	if ([minorTitle isEqualToString:value])	return;
	minorTitle = [value copy];
	[self setNeedsDisplay];
}

- (CGSize) sizeThatFits:(CGSize)size
{
	return( CGSizeMake(kTransitLegViewWidth, kTransitLegViewHeight) );
}

- (void) drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0, 0.0, kTransitLegViewWidth, kTransitLegViewHeight);
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
	UIFont *font;
	CGFloat locations[4];
	CGFloat lengths[2];
	resolution = 0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM( context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height) );

	// Background

	alignStroke = 0.0;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0, 26.0, 320.0, 128.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.62 green:0.62 blue:0.62 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.802 green:0.802 blue:0.802 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0;
	gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(1.571);
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

	stroke = 1.0;
	stroke *= resolution;

	if (stroke < 1.0) stroke = ceil(stroke);
	else stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(-0.5, 69.5);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(319.5, 69.5);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.673 green:0.673 blue:0.673 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	lengths[0] = 2.0;
	lengths[1] = 2.0;
	CGContextSetLineDash(context, 0.0, lengths, 2);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	alignStroke = 0.0;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0, 0.0, 320.0, 26.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:4];
	color = [UIColor colorWithRed:0.129 green:0.129 blue:0.129 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.166 green:0.166 blue:0.166 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0;
	color = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[2] = 0.707;
	color = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[3] = 0.289;
	gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	point = CGPointMake(160.0, 26.0);
	point2 = CGPointMake(160.0, 0.0);
	CGContextDrawLinearGradient( context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation) );
	CGContextRestoreGState(context);
	CGGradientRelease(gradient);
	CGPathRelease(path);

	stroke = 1.0;
	stroke *= resolution;

	if (stroke < 1.0) stroke = ceil(stroke);
	else stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(0.0, 153.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(320.0, 153.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1.0];
	[color setStroke];
	CGContextSetLineDash(context, 0.0, NULL, 0);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	stroke = 1.0;
	stroke *= resolution;

	if (stroke < 1.0) stroke = ceil(stroke);
	else stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(0.0, 26.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(320.0, 26.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Line

	stroke = 5.0;
	stroke *= resolution;

	if (stroke < 1.0) stroke = ceil(stroke);
	else stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(83.0, 88.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(83.0, 138.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// transfer

	drawRect = CGRectMake(70.0, 4.0, 180.0, 22.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica" size:13.0];
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[color set];
	[[self transferText] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];

	// Endpoints

	stroke = 2.0;
	stroke *= resolution;

	if (stroke < 1.0) stroke = ceil(stroke);
	else stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	drawRect = CGRectMake(80.0, 81.0, 7.0, 7.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0;
	gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(1.571);
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
	color = [UIColor colorWithRed:0.149 green:0.149 blue:0.149 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	stroke = 2.0;
	stroke *= resolution;

	if (stroke < 1.0) stroke = ceil(stroke);
	else stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	drawRect = CGRectMake(80.0, 136.0, 7.0, 7.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddEllipseInRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0;
	gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(1.571);
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
	color = [UIColor colorWithRed:0.149 green:0.149 blue:0.149 alpha:1.0];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Times

	drawRect = CGRectMake(-1.0, 74.0, 74.0, 22.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
	color = [UIColor colorWithRed:0.101 green:0.101 blue:0.101 alpha:1.0];
	[color set];
	[[self startTime] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];

	drawRect = CGRectMake(1.0, 128.0, 72.0, 22.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
	color = [UIColor colorWithRed:0.101 green:0.101 blue:0.101 alpha:1.0];
	[color set];
	[[self endTime] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];

	// Layer 1

	drawRect = CGRectMake(94.0, 74.0, 220.0, 19.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
	color = [UIColor colorWithRed:0.101 green:0.101 blue:0.101 alpha:1.0];
	[color set];
	[[self startStopTitle] drawInRect:drawRect withFont:font];

	// Layer 2

	drawRect = CGRectMake(94.0, 129.0, 220.0, 19.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
	color = [UIColor colorWithRed:0.101 green:0.101 blue:0.101 alpha:1.0];
	[color set];
	[[self endStopTitle] drawInRect:drawRect withFont:font];

	// Direction info

	drawRect = CGRectMake(80.0, 30.0, 220.0, 19.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[color set];
	[[self majorTitle] drawInRect:drawRect withFont:font];

	drawRect = CGRectMake(80.0, 48.0, 220.0, 19.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica" size:14.0];
	color = [UIColor colorWithRed:0.375 green:0.375 blue:0.375 alpha:1.0];
	[color set];
	[[self minorTitle] drawInRect:drawRect withFont:font];

	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
