//
//  NewDirectionAnnotationView.m
//  transporter
//
//  Created by Roderic Campbell on 6/30/12.
//  Copyright (c) 2012 Ljuba Miljkovic. All rights reserved.
//

#import "NewDirectionAnnotationView.h"
#import "Direction.h"
#import "Stop.h"
#import "Agency.h"
#import "Route.h"

@implementation NewDirectionAnnotationView
@synthesize direction = _direction;
@synthesize delegate = _delegate;
@synthesize mapFrame;
@synthesize pinView;


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(165.0f, 97.0f);
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.centerOffset = CGPointMake(0.0f, -40.0f);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapped {
    [self.delegate directionSelected:self.direction];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
 
    NSLog(@"%@", NSStringFromCGRect(rect));
    Stop *stop = [self.direction.stops anyObject];
    UIImage *flagImage;
    if ([stop.agency.title isEqualToString:@"AC Transit"]) {
        flagImage = [UIImage imageNamed:@"direction-pin-actransit.png"];
    }
    else if ([stop.agency.title isEqualToString:@"SF Muni"]) {
        flagImage = [UIImage imageNamed:@"direction-pin-sfmuni.png"];
    }
    else {
        NSLog(@"stop agency is %@", stop.agency.title);
        NSAssert(NO, @"Need to handle this agency in the MKAnnotationView");
    }
    
    self.pinView = [[UIImageView alloc] initWithImage:flagImage];
    self.pinView.frame = CGRectMake(55.0f, 40.0f, 64.0f, 57.0f);
    [self addSubview:self.pinView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, 0.0f, 165.0f, 40.0f);
    [button addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchDown];
    [button setImage:[UIImage imageNamed:@"direction-callout.png"] forState:UIControlStateNormal];
    [self addSubview:button];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 2.0f, 121.0f, 21.0f)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = self.direction.name;
    nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [self addSubview:nameLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 18.0f, 121.0f, 21.0f)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.direction.title;
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [self addSubview:titleLabel];
}

// given an x,y point on the map, adjust the frame of the annotation so that the base of the pin sticks into the map there.
- (void) setPoint:(CGPoint)point {
    
	// AC TRANSIT AND MUNI PINS FACE DIFFERENT DIRECTIONS AND HAVE DIFFERENT POINTS
    
	int xLocalOffset;
	int yLocalOffset;
    
	NSString *agencyShortTitle = self.direction.route.agency.shortTitle;
    
	if ([agencyShortTitle isEqualToString:@"actransit"]) {
		xLocalOffset = -5;
		yLocalOffset = 1;
	} else {
		xLocalOffset = 3;
		yLocalOffset = 1;
	}
	// set the initial position of the marker
	self.center = CGPointMake(point.x + xLocalOffset, point.y + kVerticalPinOffset + yLocalOffset);
    
	// FIGURE OUT BY HOW MUCH (DELTAX) THE MARKER NEEDS TO BE SHIFTED BY.
	// THEN SHIFT THE WHOLE MARKER BY THAT AMOUNT
	// THEN SHIFT JUST THE PIN IMAGE BACK BY THAT SAME AMOUNT
	// THE POINT IS TO HAVE A MARKER VIEW THAT ISN'T CLIPPED AT ALL.
    
	// pin x-position
	int pinX = self.center.x;
	int calloutViewWidth = self.frame.size.width;
    
	int deltaX = 0;          // the amount by which the calloutView is shifted left or right
    
	// if the callout is too far to the left
	if ( (pinX - calloutViewWidth / 2) < kMapInset ) {
        
		int oldX = self.center.x;
		int newX = oldX - (pinX - kMapInset - calloutViewWidth / 2);
        
		deltaX = newX - oldX;
        
	}
	// if the callout is too far to the right
	else if ( (pinX + calloutViewWidth / 2) > (self.mapFrame.size.width - kMapInset) ) deltaX = (self.mapFrame.size.width - kMapInset) - (pinX + calloutViewWidth / 2);
	// move the whole frame by the deltaX amount, then move the pin back by the same amount
	CGRect oldFrame = self.frame;
	CGRect newFrame = CGRectMake(oldFrame.origin.x + deltaX, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
    
	self.frame = newFrame;
    
	// adjust the position of the pin to hit the right spot, now that the
	self.pinView.center = CGPointMake(self.pinView.center.x - deltaX, self.pinView.center.y);
    
}


@end
