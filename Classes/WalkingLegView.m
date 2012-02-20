//
// WalkingLegView.m
// New Image
//
// Created by Ljuba Miljkovic on 4/22/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "Constants.h"
#import "WalkingLegView.h"

const CGFloat kWalkingLegViewWidth = 320.0;
const CGFloat kWalkingLegViewHeight = 53.0;

@implementation WalkingLegView

@synthesize centerImageView;
@synthesize time;
@synthesize majorTitle;
@synthesize minorTitle;

// Indicates whether this is the first, last, or intermediate walking leg in the trip
- (void) setPositionInTrip:(int)position {

	switch (position) {
	case kWalkingLegPositionStart:
		self.centerImageView.image = [UIImage imageNamed:@"trip-start-pin.png"];
		break;
	case kWalkingLegPositionEnd:
		self.centerImageView.image = [UIImage imageNamed:@"trip-end-pin.png"];
		break;
	case kWalkingLegPositionMid:
		self.centerImageView.image = nil;
		break;
	default:
		break;
	}
}

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {

		centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(78, 9, 10, 37)];
		centerImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:centerImageView];

		time = [@"9:10 pm" retain];
		majorTitle = [@"Walk 15 minutes" retain];
		minorTitle = [@"to Ashby BART" retain];
		[self setOpaque:NO];
	}
	return(self);
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];

	if (self) {
		time = [@"9:10 pm" retain];
		majorTitle = [@"Walk 15 minutes" retain];
		minorTitle = [@"to Ashby BART" retain];
		[self setOpaque:NO];
	}
	return(self);
}

- (void) dealloc
{

	[centerImageView release];
	[time release];
	[majorTitle release];
	[minorTitle release];
	[super dealloc];
}

- (void) setTime:(NSString *)value
{
	if ([time isEqualToString:value]) return;
	[time release];
	time = [value copy];
	[self setNeedsDisplay];
}

- (void) setMajorTitle:(NSString *)value
{
	if ([majorTitle isEqualToString:value])	return;
	[majorTitle release];
	majorTitle = [value copy];
	[self setNeedsDisplay];
}

- (void) setMinorTitle:(NSString *)value
{
	if ([minorTitle isEqualToString:value])	return;
	[minorTitle release];
	minorTitle = [value copy];
	[self setNeedsDisplay];
}

- (CGSize) sizeThatFits:(CGSize)size
{
	return( CGSizeMake(kWalkingLegViewWidth, kWalkingLegViewHeight) );
}

- (void) drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0, 0.0, kWalkingLegViewWidth, kWalkingLegViewHeight);
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
	CGFloat locations[2];
	resolution = 0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM( context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height) );

	// Layer 3

	alignStroke = 0.0;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0, -0.5, 320.0, 53.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.719 green:0.719 blue:0.719 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.802 green:0.802 blue:0.802 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
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
	point = CGPointMake(0.0, 52.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(320.0, 52.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.56 green:0.56 blue:0.56 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
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
	point = CGPointMake(0.0, 0.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(320.0, 0.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0];
	[color setStroke];
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Times

	drawRect = CGRectMake(2.0, 15.0, 71.0, 22.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
	color = [UIColor colorWithRed:0.101 green:0.101 blue:0.101 alpha:1.0];
	[color set];
	[[self time] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];

	// Directions

	drawRect = CGRectMake(94.0, 6.5, 220.0, 19.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
	color = [UIColor colorWithRed:0.101 green:0.101 blue:0.101 alpha:1.0];
	[color set];
	[[self majorTitle] drawInRect:drawRect withFont:font];

	drawRect = CGRectMake(94.0, 27.0, 220.0, 19.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica" size:14.0];
	color = [UIColor colorWithRed:0.222 green:0.222 blue:0.222 alpha:1.0];
	[color set];
	[[self minorTitle] drawInRect:drawRect withFont:font];

	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);

}

@end
