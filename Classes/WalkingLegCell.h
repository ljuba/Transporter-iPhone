//
// WalkingLegCell.h
// kronos
//
// Created by Ljuba Miljkovic on 4/22/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WalkingLegView.h"
#import <UIKit/UIKit.h>

@interface WalkingLegCell : UITableViewCell {

	WalkingLegView *walkingLegView;

}

@property (nonatomic) WalkingLegView *walkingLegView;
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame;

@end
