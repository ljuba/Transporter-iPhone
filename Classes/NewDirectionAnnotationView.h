//
//  NewDirectionAnnotationView.h
//  transporter
//
//  Created by Roderic Campbell on 6/30/12.
//  Copyright (c) 2012 Ljuba Miljkovic. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Direction;

@protocol NewDirectionAnnotationViewDelegate <NSObject>

- (void)directionSelected:(Direction *)direction;

@end

@interface NewDirectionAnnotationView : MKAnnotationView

@property (nonatomic, assign) id<NewDirectionAnnotationViewDelegate> delegate;
@property (nonatomic, strong) Direction *direction;
@end
