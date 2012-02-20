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

@property (nonatomic, retain) Stop *stop;

@property (nonatomic, retain) UIImageView *stopTitleImageView;
@property (nonatomic, retain) UILabel *stopTitleLabel;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *contents;

@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSNull *buttonRowPlaceholder;

@property int cellStatus;

@property (nonatomic, retain) NSMutableArray *errors;
@property (nonatomic, retain) NSTimer *timer;

@property BOOL isFirstPredictionsFetch;

@property (nonatomic, retain) NSMutableDictionary *predictions;

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
