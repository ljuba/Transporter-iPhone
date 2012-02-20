//
// TripInputView.m
// New Image
//
// Created by Ljuba Miljkovic on 4/21/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "TripInputView.h"

const CGFloat kTripInputViewWidth = 320.0;
const CGFloat kTripInputViewHeight = 77.0;

@implementation TripInputView

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) [self setOpaque:NO];
	return(self);
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];

	if (self) [self setOpaque:NO];
	return(self);
}

- (CGSize) sizeThatFits:(CGSize)size
{
	return( CGSizeMake(kTripInputViewWidth, kTripInputViewHeight) );
}

- (void) drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0, 0.0, kTripInputViewWidth, kTripInputViewHeight);
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
	resolution = 0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM( context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height) );

	// Background

	alignStroke = 0.0;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0, 0.0, 320.0, 77.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.41 green:0.44 blue:0.483 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.641 green:0.665 blue:0.693 alpha:1.0];
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

	// Line

	stroke = 1.0;
	stroke *= resolution;

	if (stroke < 1.0) stroke = ceil(stroke);
	else stroke = round(stroke);
	stroke /= resolution;
	alignStroke = fmod(0.5 * stroke * resolution, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(0.0, 76.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(320.0, 76.0);
	point.x = (round(resolution * point.x + alignStroke) - alignStroke) / resolution;
	point.y = (round(resolution * point.y + alignStroke) - alignStroke) / resolution;
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	color = [UIColor colorWithRed:0.173 green:0.183 blue:0.197 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, stroke);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);

	// Button

	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
