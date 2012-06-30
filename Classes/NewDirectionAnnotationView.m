//
//  NewDirectionAnnotationView.m
//  transporter
//
//  Created by Roderic Campbell on 6/30/12.
//  Copyright (c) 2012 Ljuba Miljkovic. All rights reserved.
//

#import "NewDirectionAnnotationView.h"

@implementation NewDirectionAnnotationView

@synthesize flagImage = _flagImage;
@synthesize directionName = _directionName;
@synthesize directionTitle = _directionTitle;

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
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIImage imageNamed:@"direction-callout.png"] drawInRect:CGRectMake(0.0f, 0.0f, 165.0f, 40.0f)];
    [self.flagImage drawInRect:CGRectMake(55.0f, 40.0f, 64.0f, 57.0f)];
    [[UIColor whiteColor] setFill];

    [self.directionName drawInRect:CGRectMake(10.0f, 0.0f, 121.0f, 21.0f) withFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [self.directionTitle drawInRect:CGRectMake(10.0f, 20.0f, 121.0f, 21.0f) withFont:[UIFont fontWithName:@"Helvetica" size:13]];
}


@end
