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

@interface ButtonBarCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *previousStopButton;
@property (nonatomic, strong) IBOutlet UIButton *nextStopButton;
@property (nonatomic, strong) IBOutlet UIButton *liveRouteButton;

@property (nonatomic, strong) Direction *direction;
@property (nonatomic, strong) Stop *stop;
@property (nonatomic, strong) Stop *nextStop;
@property (nonatomic, strong) Stop *previousStop;

- (IBAction) goToPreviousStop:(id)sender;
- (IBAction) goToNextStop:(id)sender;
- (IBAction) loadLiveRoute:(id)sender;
- (void) configureButtons;

- (BOOL) thereIsPreviousStop;
- (BOOL) thereIsNextStop;

@end
