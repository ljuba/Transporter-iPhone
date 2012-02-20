//
// FavoritesVC.h
// kronos
//
// Created by Ljuba Miljkovic on 3/23/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PredictionsManagerDelegate.h"
#import <UIKit/UIKit.h>

#import "FavoriteStopsDelegate.h"

@interface FavoritesVC : UIViewController <PredictionsManagerDelegate> {

	UISegmentedControl *segmentedControl;
	UIBarButtonItem *reloadPredictionsButton;
	UIBarButtonItem *editButton;

	UITableView *tableView;

	FavoriteStopsDelegate *stopsDelegate;

	NSTimer *timer;

	UIImageView *noFavoritesMessageView;

	UIButton *participateButton;

}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *reloadPredictionsButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) UIImageView *noFavoritesMessageView;

@property (nonatomic, retain) FavoriteStopsDelegate *stopsDelegate;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) UIButton *participateButton;

- (void) loadNextViewController:(NSNotification *)note;
- (void) tapSegmentedControl;
- (void) requestPredictions;
- (IBAction) toggleEditingMode;

@end
