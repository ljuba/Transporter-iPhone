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

@property (nonatomic) UISegmentedControl *segmentedControl;
@property (nonatomic) IBOutlet UIBarButtonItem *reloadPredictionsButton;
@property (nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIImageView *noFavoritesMessageView;

@property (nonatomic) FavoriteStopsDelegate *stopsDelegate;

@property (nonatomic) NSTimer *timer;

@property (nonatomic) UIButton *participateButton;

- (void) loadNextViewController:(NSNotification *)note;
- (void) tapSegmentedControl;
- (void) requestPredictions;
- (IBAction) toggleEditingMode;

@end
