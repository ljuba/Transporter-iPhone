//
// TripDetailsVC.h
// kronos
//
// Created by Ljuba Miljkovic on 4/20/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Trip.h"
#import <UIKit/UIKit.h>

extern const CGFloat kTransitLegTransferHeight;

@interface TripDetailsTVC : UITableViewController {

	Trip *trip;
	NSDateFormatter *dateFormatter;

	NSMutableArray *contents;
	NSIndexPath *lastIndexPath;
	NSNull *buttonRowPlaceholder;

}

@property (nonatomic) NSNull *buttonRowPlaceholder;
@property (nonatomic) Trip *trip;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSMutableArray *contents;
@property (nonatomic) NSIndexPath *lastIndexPath;

- (void) requestPredictions;
- (void) didReceivePredictions:(NSDictionary *)predictions;
- (NSDate *) updatedArrivalDateGivenExistingArrivalDate:(NSDate *)existingArrivalDate andPredictionArrivals:(NSArray *)arrivals;

@end
