//
// DirectionAnnotationView.h
// kronos
//
// Created by Ljuba Miljkovic on 3/30/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Agency.h"
#import "Direction.h"
#import "Route.h"
#import <UIKit/UIKit.h>

#define kVerticalPinOffset -45
#define kMapInset 10                    // callout bubbles cannot get any closer to the edge of the screen than this

@interface DirectionAnnotationView : UIView 

@property (nonatomic, strong) IBOutlet UIImageView *pinView;
@property (nonatomic, strong) Direction *direction;
@property (nonatomic, strong) IBOutlet UIView *calloutView;
@property (nonatomic, strong) IBOutlet UIButton *calloutButton;

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *subtitle;

@property (nonatomic) CGRect mapFrame;

- (void) setDirection:(Direction *)_direction;
- (void) setPoint:(CGPoint)point;
- (IBAction) buttonTapped:(id)sender;

@end
