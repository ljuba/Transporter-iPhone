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

@interface StopDetails : UIViewController <UITableViewDelegate, UITableViewDataSource, PredictionsManagerDelegate> {

	Stop *stop;

	UIImageView *stopTitleImageView;
	UILabel *stopTitleLabel;

	UITableView *tableView;
	NSMutableArray *contents;

	NSIndexPath *lastIndexPath;
	NSNull *buttonRowPlaceholder;

	int cellStatus;

	NSMutableArray *errors;
	NSTimer *timer;

	BOOL isFirstPredictionsFetch;

	NSMutableDictionary *predictions;

	int tableHeaderHeight;
	int tableFooterHeight;

}

@property (nonatomic) Stop *stop;

@property (nonatomic) UIImageView *stopTitleImageView;
@property (nonatomic) UILabel *stopTitleLabel;

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *contents;

@property (nonatomic) NSIndexPath *lastIndexPath;
@property (nonatomic) NSNull *buttonRowPlaceholder;

@property int cellStatus;

@property (nonatomic) NSMutableArray *errors;
@property (nonatomic) NSTimer *timer;

@property BOOL isFirstPredictionsFetch;

@property (nonatomic, strong) NSMutableDictionary *predictions;

@property int tableHeaderHeight;
@property int tableFooterHeight;

- (void) setupInitialContents;
- (void) setupContentsBasedOnPredictions;

- (void) requestPredictions;
- (void) didReceivePredictions:(NSDictionary *)predictions;

- (void) goToPreviousStop:(NSNotification *)note;
- (void) goToNextStop:(NSNotification *)note;
- (void) enableUserInteraction;
- (void) loadLiveRoute:(NSNotification *)note;

@end
