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

@implementation NewDirectionAnnotationView
@synthesize direction = _direction;
@synthesize delegate = _delegate;

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
    
    [[UIImage imageNamed:@"direction-callout.png"] drawInRect:CGRectMake(0.0f, 0.0f, 165.0f, 40.0f)];
    [flagImage drawInRect:CGRectMake(55.0f, 40.0f, 64.0f, 57.0f)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, 0.0f, 165.0f, 40.0f);
    [button setImage:[UIImage imageNamed:@"direction-callout.png"] forState:UIControlStateNormal];
    [self addSubview:button];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 2.0f, 121.0f, 21.0f)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = self.direction.name;
    nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    [self addSubview:nameLabel];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 17.0f, 121.0f, 21.0f)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.direction.title;
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [self addSubview:titleLabel];
}


@end
