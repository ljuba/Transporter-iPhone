//
// ButtonBarCell.h
//
// Created by Ljuba Miljkovic on 3/16/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DataHelper.h"
#import "Direction.h"
#import "Stop.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ButtonBarCell : UITableViewCell {

	UIButton *previousStopButton;
	UIButton *nextStopButton;
	UIButton *liveRouteButton;

	Direction *direction;
	Stop *stop;
	Stop *nextStop;
	Stop *previousStop;

}

@property (nonatomic, retain) IBOutlet UIButton *previousStopButton;
@property (nonatomic, retain) IBOutlet UIButton *nextStopButton;
@property (nonatomic, retain) IBOutlet UIButton *liveRouteButton;

@property (nonatomic, retain) Direction *direction;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) Stop *nextStop;
@property (nonatomic, retain) Stop *previousStop;

- (IBAction) goToPreviousStop:(id)sender;
- (IBAction) goToNextStop:(id)sender;
- (IBAction) loadLiveRoute:(id)sender;
- (void) configureButtons;

- (BOOL) thereIsPreviousStop;
- (BOOL) thereIsNextStop;

@end
