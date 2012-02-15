//
//  WalkingLegCell.h
//  kronos
//
//  Created by Ljuba Miljkovic on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WalkingLegView.h"

@interface WalkingLegCell : UITableViewCell {

	WalkingLegView *walkingLegView;
	
}

@property (nonatomic, retain) WalkingLegView *walkingLegView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame;

@end
