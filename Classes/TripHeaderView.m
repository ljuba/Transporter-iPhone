//
// TripHeaderView.m
// New Image
//
// Created by Ljuba Miljkovic on 4/22/10
// Copyright Like Thought, LLC. All rights reserved.
// THIS CODE IS FOR EVALUATION ONLY. YOU MAY NOT USE IT FOR ANY OTHER PURPOSE UNLESS YOU PURCHASE A LICENSE FOR OPACITY.
//

#import "TripHeaderView.h"

const CGFloat kTripHeaderViewWidth = 320.0;
const CGFloat kTripHeaderViewHeight = 22.0;

@implementation TripHeaderView

@synthesize startTitle;
@synthesize durationTitle;

- (id) init
{

	CGRect frame = CGRectMake(0, 0, kTripHeaderViewWidth, kTripHeaderViewHeight);

	self = [super initWithFrame:frame];

	if (self) {
		startTitle = [@"Current Location" retain];
		durationTitle = [@"0h 52m" retain];
		[self setOpaque:NO];
	}
	return(self);
}

- (id) initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];

	if (self) {
		startTitle = [@"Current Location" retain];
		durationTitle = [@"0h 52m" retain];
		[self setOpaque:NO];
	}
	return(self);
}

- (void) dealloc
{
	[startTitle release];
	[durationTitle release];
	[super dealloc];
}

- (void) setStartTitle:(NSString *)value
{
	if ([startTitle isEqualToString:value])	return;
	[startTitle release];
	startTitle = [value copy];
	[self setNeedsDisplay];
}

- (void) setDurationTitle:(NSString *)value
{
	if ([durationTitle isEqualToString:value]) return;
	[durationTitle release];
	durationTitle = [value copy];
	[self setNeedsDisplay];
}

- (CGSize) sizeThatFits:(CGSize)size
{
	return( CGSizeMake(kTripHeaderViewWidth, kTripHeaderViewHeight) );
}

- (void) drawRect:(CGRect)dirtyRect
{
	CGRect imageBounds = CGRectMake(0.0, 0.0, kTripHeaderViewWidth, kTripHeaderViewHeight);
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
	drawRect = CGRectMake(0.0, 0.0, 320.0, 22.0);
	drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution;
	drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	CGPathAddRect(path, NULL, drawRect);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.135 green:0.135 blue:0.135 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.192 green:0.192 blue:0.192 alpha:1.0];
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

	// Layer 2

	drawRect = CGRectMake(230.0, 2.0, 84.0, 22.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[color set];
	[[self durationTitle] drawInRect:drawRect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];

	drawRect = CGRectMake(6.0, 2.0, 243.0, 22.0);
	drawRect.origin.x = round(resolution * drawRect.origin.x) / resolution;
	drawRect.origin.y = round(resolution * drawRect.origin.y) / resolution;
	drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
	drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
	font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	[color set];
	[[self startTitle] drawInRect:drawRect withFont:font];

	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end
