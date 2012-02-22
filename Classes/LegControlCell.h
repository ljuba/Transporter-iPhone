//
// LegControlCell.h
// transporter
//
// Created by Ljuba Miljkovic on 4/25/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegControlCell : UITableViewCell {

	UIButton *rerouteButton;
	UIButton *segmentMapButton;

}

@property (nonatomic) UIButton *rerouteButton;
@property (nonatomic) UIButton *segmentMapButton;

@end
