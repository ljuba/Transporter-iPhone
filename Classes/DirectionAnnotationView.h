//
//  DirectionAnnotationView.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Direction.h"
#import "Route.h"
#import "Agency.h"

#define kVerticalPinOffset -45
#define kMapInset 10			//callout bubbles cannot get any closer to the edge of the screen than this


@interface DirectionAnnotationView : UIView {

	UIImageView *pinView;
	UIView *calloutView;
	UIButton *calloutButton;
	
	UILabel *title;
	UILabel *subtitle;
	
	Direction *direction;
	
	CGRect mapFrame;

}

@property (nonatomic, retain) IBOutlet UIImageView *pinView;

@property (nonatomic, retain) IBOutlet UIView *calloutView;
@property (nonatomic, retain) IBOutlet UIButton *calloutButton;

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *subtitle;

@property (nonatomic) CGRect mapFrame;

- (void)setDirection:(Direction *)_direction;
- (void)setPoint:(CGPoint)point;
- (IBAction)buttonTapped:(id)sender;

@end
