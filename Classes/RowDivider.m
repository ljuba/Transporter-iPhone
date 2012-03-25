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

@synthesize title, backgroundImage;

- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self) {
		title = @"New Title";
		[self setOpaque:NO];
        
        self.backgroundImage = [UIImage imageNamed:@"divider-background.png"];
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
	CGFloat resolution;
	CGRect drawRect;
	UIColor *color;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

	UIFont *font;
	resolution = 0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height);

	CGContextSaveGState(context);
	CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
	CGContextScaleCTM( context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height) );

	// Background
    [backgroundImage drawInRect:dirtyRect];
	
	// Layer 3

	if ( [[UIScreen mainScreen] respondsToSelector:@selector(scale)]&&([[UIScreen mainScreen] scale] == 2) )
		// Retina Display
		drawRect = CGRectMake(8.0, 1.0, 160.0, 18.0);
	else
		// Regular Display
		drawRect = CGRectMake(9.0, 0.0, 160.0, 18.0);
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
