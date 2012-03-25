//
// RowDivider.m
// New Image
//
// Created by Ljuba Miljkovic on 4/25/10
// Copyright Like Thought, LLC. All rights reserved.
//

#import "Constants.h"
#import "RowDivider.h"

const CGFloat kRowDividerWidth = 320.0;

@implementation RowDivider

@synthesize title;

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		title = @"New Title";
		[self setOpaque:NO];
	}
	return(self);
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];

	if (self) {
		title = @"New Title";
		[self setOpaque:NO];
	}
	return(self);
}


- (void) setTitle:(NSString *)value
{
	if ([title isEqualToString:value]) return;
	title = [value copy];
	[self setNeedsDisplay];
}

- (CGSize) sizeThatFits:(CGSize)size
{
	return( CGSizeMake(kRowDividerWidth, kRowDividerHeight) );
}

- (void) drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0, 0.0, kRowDividerWidth, kRowDividerHeight);
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
	UIFont *font;
	CGFloat locations[2];
	resolution = 0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM( context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height) );

	// Layer 1

	alignStroke = 0.0;
	path = CGPathCreateMutable();
	drawRect = CGRectMake(0.0, 0.0, 320.0, 18.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.238 green:0.238 blue:0.238 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.319 green:0.319 blue:0.319 alpha:1.0];
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

	// Layer 3

	if ( [[UIScreen mainScreen] respondsToSelector:@selector(scale)]&&([[UIScreen mainScreen] scale] == 2) )
		// Retina Display
		drawRect = CGRectMake(8.0, 1.0, 160.0, 18.0);
	else
		// Regular Display
		drawRect = CGRectMake(8.0, 0.0, 160.0, 18.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[color set];
	[[self title] drawInRect:drawRect withFont:font];

	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
