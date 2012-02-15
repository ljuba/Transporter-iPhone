//
//  StopNameRow.h
//  kronos
//
//  Created by Ljuba Miljkovic on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StopNameRow : UIView {

	NSString *stopName;
	
	UIImage *backgroundImage;
	
}

- (id)initWithStopName:(NSString *)name agencyShortTitle:(NSString *)agencyShortTitle;
- (void)setBackgroundWithStopName:(NSString *)name agencyShortTitle:(NSString *)agencyShortTitle;

@property (nonatomic, retain) NSString *stopName;

@property (nonatomic, retain) UIImage *backgroundImage;



@end
