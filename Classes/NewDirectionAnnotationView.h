//
//  NewDirectionAnnotationView.h
//  transporter
//
//  Created by Roderic Campbell on 6/30/12.
//  Copyright (c) 2012 Ljuba Miljkovic. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface NewDirectionAnnotationView : MKAnnotationView

@property (nonatomic, retain) UIImage *flagImage;
@property (nonatomic, retain) NSString *directionName;
@property (nonatomic, retain) NSString *directionTitle;
@end
