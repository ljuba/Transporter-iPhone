//
// TripDetailsVC.m
// kronos
//
// Created by Ljuba Miljkovic on 4/20/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripDetailsTVC.h"

#import "TransitLeg.h"
#import "TransitLegCell.h"
#import "TransitLegView.h"

#import "WalkingLeg.h"
#import "WalkingLegCell.h"
#import "WalkingLegView.h"

#import "DataHelper.h"
#import "TripHeaderView.h"

#import "Constants.h"
#import "LegControlCell.h"

#import "Prediction.h"
#import "PredictionRequest.h"
#import "PredictionsManager.h"
#import "kronosAppDelegate.h"

const CGFloat kTransitLegTransferHeight = 26.0;

@implementation TripDetailsTVC

@synthesize trip, dateFormatter, contents, lastIndexPath, buttonRowPlaceholder;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[super viewDidLoad];

	self.title = @"Directions";
	self.view.backgroundColor = [UIColor grayColor];

	// SETUP TABLE VIEW
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.showsVerticalScrollIndicator = NO;

	// SETUP DATE FORMATTER
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setPMSymbol:@"pm"];
	[dateFormatter setAMSymbol:@"am"];

	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[dateFormatter setLocale:usLocale];
	[usLocale release];

	// SETUP TABLE VIEW HEADER AND FOOTER
	TripHeaderView *tripHeaderView = [[TripHeaderView alloc] init];
	tripHeaderView.startTitle = trip.startTitle;
	tripHeaderView.durationTitle = [trip durationLabelText];
	self.tableView.tableHeaderView = tripHeaderView;
	[tripHeaderView release];

	TripHeaderView *tripFooterView = [[TripHeaderView alloc] init];
	tripFooterView.startTitle = trip.endTitle;
	tripFooterView.durationTitle = [trip costLabelText];
	self.tableView.tableFooterView = tripFooterView;
	[tripFooterView release];

	self.contents = [NSMutableArray arrayWithArray:trip.legs];

	self.lastIndexPath = nil;
	self.buttonRowPlaceholder = [NSNull null];

}

- (void) viewDidAppear:(BOOL)animated {

	[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(requestPredictions) userInfo:nil repeats:YES];

}

#pragma mark -
#pragma mark Table View

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return([contents count]);

}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

	return(1);

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	int row = indexPath.row;

	id leg = [contents objectAtIndex:row];

	if ([leg isMemberOfClass:[WalkingLeg class]]) return(kWalkingLegViewHeight);
	else if ([leg isMemberOfClass:[NSNull class]]) return(46);
	else {

		TransitLeg *transitLeg = (TransitLeg *)leg;

		if (transitLeg.timeToTransfer == kTimeToTransferNoTransfer) return(kTransitLegViewHeight - kTransitLegTransferHeight);
		else return(kTransitLegViewHeight);
	}
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {

	int row = indexPath.row;

	id leg = [contents objectAtIndex:row];

	// BUTTON ROW CELL
	if ([leg isMemberOfClass:[NSNull class]]) {

		static NSString *LegControlCellID = @"LegControlCellID";

		LegControlCell *cell = (LegControlCell *)[tableView dequeueReusableCellWithIdentifier:LegControlCellID];

		if (cell == nil) cell = [[[LegControlCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LegControlCellID] autorelease];
		return(cell);

	}
	// WALKING LEG CELL
	else if ([leg isMemberOfClass:[WalkingLeg class]]) {

		WalkingLeg *walkingLeg = (WalkingLeg *)leg;

		static NSString *CellIdentifier = @"WalkingLegCell";

		WalkingLegCell *cell = (WalkingLegCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		if (cell == nil) {

			CGRect frame = CGRectMake(0, 0, 320, kWalkingLegViewHeight);
			cell = [[[WalkingLegCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier frame:frame] autorelease];

		}
		// SET CELL CONTENTS
		cell.walkingLegView.time = [dateFormatter stringFromDate:walkingLeg.date];

		int walkingTime = round(walkingLeg.duration / 60);

		NSString *minuteString = @"minutes";

		if (walkingTime == 1) minuteString = @"minute";
		cell.walkingLegView.majorTitle = [NSString stringWithFormat:@"Walk %i %@", walkingTime, minuteString];
		cell.walkingLegView.minorTitle = [NSString stringWithFormat:@"to %@", walkingLeg.destinationTitle];

		// Set walking leg position: does this leg appear at the beginning, end, or middle of a trip
		if (row == 0) [cell.walkingLegView setPositionInTrip:kWalkingLegPositionStart];

		else if (row == [contents count] - 1) [cell.walkingLegView setPositionInTrip:kWalkingLegPositionEnd];

		else [cell.walkingLegView setPositionInTrip:kWalkingLegPositionMid];
		return(cell);
	}
	// TRANSIT LEG CELL
	else {

		TransitLeg *transitLeg = (TransitLeg *)leg;

		static NSString *CellIdentifier = @"TransitLegCell";

		TransitLegCell *cell = (TransitLegCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

		// determine whether this cell has a transfer time bar and adjust the frame to match
		CGRect frame;
		NSString *transferMessage = nil;

		if (transitLeg.timeToTransfer == kTimeToTransferNoTransfer) frame = CGRectMake(0, -kTransitLegTransferHeight, 320, kTransitLegViewHeight);
		else {
			frame = CGRectMake(0, 0, 320, kTransitLegViewHeight);

			if (transitLeg.timeToTransfer == kTimeToTransferTimedTransfer) transferMessage = @"timed transfer";
			else {
				int timeToTransfer = round(transitLeg.timeToTransfer / 60);

				NSString *minuteString = @"minutes";

				if (timeToTransfer == 1) minuteString = @"minute";
				transferMessage = [NSString stringWithFormat:@"%i %@ to transfer", timeToTransfer, minuteString];
			}
		}

		if (cell == nil) cell = [[[TransitLegCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier frame:frame] autorelease];
		// GET TRANSIT LEG INFORMATION
		Direction *direction = [transitLeg.directions objectAtIndex:0];
		Agency *agency = direction.route.agency;

		// SET GENERAL INFORMATION FOR TRANSIT LEG CELL/VIEW
		cell.frame = frame;

		cell.transitLegView.startTime = [dateFormatter stringFromDate:transitLeg.startDate];
		cell.transitLegView.endTime = [dateFormatter stringFromDate:transitLeg.endDate];
		cell.transitLegView.startStopTitle = transitLeg.startStop.title;
		cell.transitLegView.endStopTitle = transitLeg.endStop.title;
		cell.transitLegView.transferText = transferMessage;
		[cell.transitLegView setRoute:direction.route];

		// SET INFORMATION SPECIFIC TO BART/NEXTBUS AGENCIES
		if ([agency.shortTitle isEqual:@"bart"]) {

			cell.transitLegView.majorTitle = direction.title;
			cell.transitLegView.minorTitle = @"HI";

		} else {

			cell.transitLegView.majorTitle = direction.name;
			cell.transitLegView.minorTitle = [NSString stringWithFormat:@"→ %@", direction.title];

		}
		return(cell);
	}
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	int row = indexPath.row;

	id leg = [contents objectAtIndex:row];

	if ([leg isMemberOfClass:[WalkingLeg class]]) return(nil);
	return(indexPath);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	int row = indexPath.row;
	int section = indexPath.section;

	// if you tapped on a row that is already activated, retract it's buttons...
	if (indexPath == lastIndexPath) {
		NSLog(@"retract tapped");
		lastIndexPath = nil;

		int buttonRowIndex = [self.contents indexOfObject:buttonRowPlaceholder];
		[self.contents removeObjectAtIndex:buttonRowIndex];

		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:buttonRowIndex inSection:indexPath.section]]
		 withRowAnimation:UITableViewRowAnimationFade];

	} else {
		// if you tap a retracted row, show its button
		if (lastIndexPath == nil) {
			NSLog(@"show tapped");

			[self.contents insertObject:buttonRowPlaceholder atIndex:row + 1];

			NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:row + 1 inSection:section];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationBottom];

			self.lastIndexPath = indexPath;  // retained so it stays in the ivar

			tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:section]
			 atScrollPosition:UITableViewScrollPositionNone animated:YES];
			// tableView.contentInset = UIEdgeInsetsMake(-tableHeaderHeight, 0, -tableFooterHeight, 0);

		} else {
			// otherwise retract the previously active row's buttons and show the current ones
			NSLog(@"retract previous and show tapped");

			// FIND THE LEG OBJECT THAT WAS TAPPED
			id leg = [contents objectAtIndex:row];

			// remove button bar placeholder from content array
			int indexToDelete = [contents indexOfObject:buttonRowPlaceholder];
			[self.contents removeObjectAtIndex:indexToDelete];

			// determine the next index of the row that was tapped and add a button row placeholder there
			int indexToAdd = [contents indexOfObject:leg];
			[contents insertObject:buttonRowPlaceholder atIndex:indexToAdd + 1];

			[tableView beginUpdates];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToDelete inSection:lastIndexPath.section]]
			 withRowAnimation:UITableViewRowAnimationFade];

			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToAdd + 1 inSection:section]]
			 withRowAnimation:UITableViewRowAnimationFade];

			[tableView endUpdates];

			self.lastIndexPath = [NSIndexPath indexPathForRow:indexToAdd inSection:section];         // retained so it stays in the ivar

			tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexToAdd + 1 inSection:section]
			 atScrollPosition:UITableViewScrollPositionNone animated:YES];
			// tableView.contentInset = UIEdgeInsetsMake(-tableHeaderHeight, 0, -tableFooterHeight, 0);
		}
	}
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];

}

#pragma mark -
#pragma mark Predictions

// submits a request to the PredictionsManager for predictions of the displayed bart stops. results will be sent to didReceivePredictions
- (void) requestPredictions {

	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	PredictionsManager *predictionsManager = appDelegate.predictionsManager;

	NSMutableArray *requests = [NSMutableArray array];

	for (id leg in trip.legs)

		if ([leg isMemberOfClass:[TransitLeg class]]) {

			TransitLeg *transitLeg = (TransitLeg *)leg;

			PredictionRequest *startRequest = [[PredictionRequest alloc] init];
			PredictionRequest *endRequest = [[PredictionRequest alloc] init];

			startRequest.agencyShortTitle = transitLeg.agency.shortTitle;
			endRequest.agencyShortTitle = transitLeg.agency.shortTitle;

			if (transitLeg.agency.shortTitle == @"bart") {

				startRequest.stopTag = transitLeg.startStop.tag;
				startRequest.isMainRoute = NO;

				endRequest.stopTag = transitLeg.endStop.tag;
				endRequest.isMainRoute = NO;

			} else {

				startRequest.stopTag = transitLeg.startStop.tag;
				startRequest.route = [[transitLeg.directions objectAtIndex:0] route];
				startRequest.isMainRoute = NO;

				endRequest.stopTag = transitLeg.endStop.tag;
				endRequest.route = [[transitLeg.directions objectAtIndex:0] route];
				endRequest.isMainRoute = NO;

			}
			[requests addObject:startRequest];
			[requests addObject:endRequest];

			[startRequest release];
			[endRequest release];
		}
	// request predictions for the stops in the favorites screen
	[NSThread detachNewThreadSelector:@selector(requestPredictionsForRequests:) toTarget:predictionsManager withObject:requests];

	// [predictionsManager requestPredictionsForRequests:requests];
	NSLog(@"TripDetails: predictions requested"); /* DEBUG LOG */

}

// method called when PredictionsManager returns predictions.
- (void) didReceivePredictions:(NSDictionary *)predictions {

	// show error message if there is one
	if ([predictions objectForKey:@"error"] != nil)	return;

	else {

		for (id leg in trip.legs)

			if ([leg isMemberOfClass:[TransitLeg class]]) {

				TransitLeg *transitLeg = (TransitLeg *)leg;

				if (transitLeg.agency.shortTitle == @"bart") {

					// match the stop
					Direction *legDirection = [transitLeg.directions objectAtIndex:0];

					NSString *tagOfLastStopInLegDirection = [legDirection.stopOrder lastObject];
					NSLog(@"LAST STOP OF DIRECTION: %@", tagOfLastStopInLegDirection);

					Stop *lastStop = [DataHelper stopWithTag:tagOfLastStopInLegDirection inAgency:[DataHelper agencyWithShortTitle:@"bart"]];

					Prediction *startPrediction = [predictions objectForKey:transitLeg.startStop.tag];

					if (startPrediction != nil) {

						NSArray *startArrivals = [startPrediction.arrivals objectForKey:lastStop.tag];

						// now we have the closest prediction arrival to the existing time
						transitLeg.startDate = [self updatedArrivalDateGivenExistingArrivalDate:transitLeg.startDate andPredictionArrivals:startArrivals];

					}
					Prediction *endPrediction = [predictions objectForKey:transitLeg.endStop.tag];

					if (endPrediction != nil) {

						// match the stop

						NSArray *endArrivals = [endPrediction.arrivals objectForKey:lastStop.tag];

						// now we have the closest prediction arrival to the existing time
						transitLeg.endDate = [self updatedArrivalDateGivenExistingArrivalDate:transitLeg.endDate andPredictionArrivals:endArrivals];

					}
				} else {}
			}
	}
	[self.tableView reloadData];

}

- (NSDate *) updatedArrivalDateGivenExistingArrivalDate:(NSDate *)existingArrivalDate andPredictionArrivals:(NSArray *)arrivals {

	NSTimeInterval minimumTimeInterval = 99999999;
	NSDate *updatedDate = nil;

	for (NSDictionary *arrival in arrivals) {

		NSString *minutesString = [arrival objectForKey:@"minutes"];
		double minutes = [minutesString doubleValue];

		NSDate *predictionArrivalDate = [NSDate dateWithTimeIntervalSinceNow:minutes * 60];

		// this it the value that we want to minimize
		NSTimeInterval timeInterval = [existingArrivalDate timeIntervalSinceDate:predictionArrivalDate];

		if ( fabs(minimumTimeInterval) > fabs(timeInterval) ) {

			minimumTimeInterval = timeInterval;
			updatedDate = predictionArrivalDate;

		}
	}
	return(updatedDate);

}

#pragma mark -
#pragma mark Memory

- (void) dealloc {

	[buttonRowPlaceholder release];
	[contents release];
	[dateFormatter release];
	[trip release];

	[super dealloc];
}

@end
