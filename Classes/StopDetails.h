//
// StopDetails.h
// transporter
//
// Created by Ljuba Miljkovic on 4/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Agency.h"
#import "ButtonBarCell.h"
#import "Constants.h"
#import "DataHelper.h"
#import "FavoritesManager.h"
#import "LineCell.h"
#import "LineCellView.h"
#import "LiveRouteTVC.h"
#import "Prediction.h"
#import "PredictionsManager.h"
#import "Route.h"
#import "RowDivider.h"
#import "Stop.h"
#import "kronosAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface StopDetails : UIViewController <UITableViewDelegate, UITableViewDataSource, PredictionsManagerDelegate>

@property (nonatomic, strong) Stop *stop;

@property (nonatomic, strong) UIImageView *stopTitleImageView;
@property (nonatomic, strong) UILabel *stopTitleLabel;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contents;

@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (nonatomic, strong) NSNull *buttonRowPlaceholder;

@property int cellStatus;

@property (nonatomic, strong) NSMutableArray *errors;
@property (nonatomic) NSTimer *timer;

@property BOOL isFirstPredictionsFetch;

@property (nonatomic, strong) NSMutableDictionary *predictions;

@property int tableHeaderHeight;
@property int tableFooterHeight;

- (id)initWithStop:(Stop *)newStop;

- (void) setupInitialContents;
- (void) setupContentsBasedOnPredictions;

- (void) requestPredictions;
- (void) didReceivePredictions:(NSDictionary *)predictions;

- (void) goToPreviousStop:(NSNotification *)note;
- (void) goToNextStop:(NSNotification *)note;
- (void) enableUserInteraction;
- (void) loadLiveRoute:(NSNotification *)note;

@end
