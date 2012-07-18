//
//  NewDirectionAnnotationView.h
//  transporter
//
//  Created by Roderic Campbell on 6/30/12.
//  Copyright (c) 2012 Ljuba Miljkovic. All rights reserved.
//

#import <MapKit/MapKit.h>

#define kVerticalPinOffset -45
#define kMapInset 10                    // callout bubbles cannot get any closer to the edge of the screen than this

@class Direction;

@protocol NewDirectionAnnotationViewDelegate <NSObject>

- (void)directionSelected:(Direction *)direction;

@end

@interface NewDirectionAnnotationView : MKAnnotationView

@property (nonatomic, assign) id<NewDirectionAnnotationViewDelegate> delegate;
@property (nonatomic, strong) Direction *direction;
@property (nonatomic, assign) CGRect mapFrame;
@property (nonatomic, strong) UIImageView *pinView;

- (void) setPoint:(CGPoint)point;


@end
