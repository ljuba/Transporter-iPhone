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


}

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *reloadPredictionsButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIImageView *noFavoritesMessageView;

@property (nonatomic, strong) FavoriteStopsDelegate *stopsDelegate;

@property (nonatomic, strong) NSTimer *timer;


- (void) loadNextViewController:(NSNotification *)note;
- (void) tapSegmentedControl;
- (void) requestPredictions;
- (IBAction) toggleEditingMode;

@end
