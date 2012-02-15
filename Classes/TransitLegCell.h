//
//  TransitLegCell.h
//  kronos
//
//  Created by Ljuba Miljkovic on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitLegView.h"


@interface TransitLegCell : UITableViewCell {

	TransitLegView *transitLegView;
		
}

@property (nonatomic, retain) TransitLegView *transitLegView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame;

@end
