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

@property (nonatomic, retain) NSNull *buttonRowPlaceholder;
@property (nonatomic, retain) Trip *trip;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSMutableArray *contents;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;

- (void) requestPredictions;
- (void) didReceivePredictions:(NSDictionary *)predictions;
- (NSDate *) updatedArrivalDateGivenExistingArrivalDate:(NSDate *)existingArrivalDate andPredictionArrivals:(NSArray *)arrivals;

@end
