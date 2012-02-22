//
// BartStopDetails.m
// transporter
//
// Created by Ljuba Miljkovic on 4/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BartStopDetails.h"
#import "DestinationCellView.h"

@implementation BartStopDetails

@synthesize platforms;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[super viewDidLoad];

	stopTitleImageView.image = [UIImage imageNamed:@"stop-name-background-bart.png"];

	// SETUP THE CONTENTS ARRAY WITH SHOW=TRUE DIRECTIONS AND FAVORITED DIRECTIONS
	[self setupInitialContents];

}

- (void) setupInitialContents {

	[super setupInitialContents];

	// setup stop name
	self.stopTitleLabel.text = stop.title;

	// CREATE A DICTIONARY OF PLATFORM NUMBERS AND STOP TAGS
	NSMutableDictionary *platformsDict = [[NSMutableDictionary alloc] init];

	// load platforms xml file
	NSString *platformsPath = [[NSBundle mainBundle] pathForResource:@"bart-platforms" ofType:@"xml"];
	NSData *platformsData = [NSData dataWithContentsOfFile:platformsPath];

	CXMLDocument *platformParser = [[CXMLDocument alloc] initWithData:platformsData options:0 error:nil];

	NSString *xPath = [NSString stringWithFormat:@"//agency/stop[@tag='%@']/platform", stop.tag];

	NSArray *platformNodes = [platformParser nodesForXPath:xPath error:nil];

	for (CXMLElement *platformElement in platformNodes) {

		// add each destination in the platform to the platformsDict for that platform number
		NSMutableArray *destinationStopTags = [[NSMutableArray alloc] init];
		NSArray *destinationNodes = [platformElement nodesForXPath:@"./destination" error:nil];

		for (CXMLElement *destinationNode in destinationNodes) {

			NSString *stopTag = [destinationNode stringValue];
			[destinationStopTags addObject:stopTag];

		}
		NSString *platformNumber = [[platformElement attributeForName:@"number"] stringValue];
		[platformsDict setObject:destinationStopTags forKey:platformNumber];
	}
	// CREATE ARRAY OF SORTED PLATFORMS FROM THE NUMBERS AT THIS STOP
	self.platforms = [NSMutableArray arrayWithArray:[platformsDict allKeys]];
	NSSortDescriptor *platformSorter = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
	[platforms sortUsingDescriptors:[NSArray arrayWithObject:platformSorter]];

	NSLog(@"PLATFORMS: %@", platforms); /* DEBUG LOG */

	NSLog(@"PLATFORM DICTIONARY: %@", platformsDict);

	// CREATE A CONTENTS ARRAY WITH AN ARRAY FOR EACH PLATFORM, WITH DESTINATIONS ORDERED ALPHABETICALLY
	for (NSString *platformNumber in platforms) {

		NSArray *destinationStopTags = [platformsDict objectForKey:platformNumber];

		NSMutableArray *platformDestinations = [[NSMutableArray alloc] init];

		for (NSString *destinationStopTag in destinationStopTags) {

			Agency *agency = [DataHelper agencyFromStop:stop];
			Stop *destinationStop = [DataHelper stopWithTag:destinationStopTag inAgency:agency];

			Destination *dest = [[Destination alloc] initWithDestinationStop:destinationStop forStop:stop];
			[platformDestinations addObject:dest];

		}
		// sort the destination objects by the stop title
		NSSortDescriptor *alphabeticSorter = [[NSSortDescriptor alloc] initWithKey:@"destinationStop.title" ascending:YES];
		[platformDestinations sortUsingDescriptors:[NSArray arrayWithObject:alphabeticSorter]];

		[contents addObject:platformDestinations];


	}

}

#pragma mark -
#pragma mark Navigation Buttons

- (void) goToPreviousStop:(NSNotification *)note {

	[super goToPreviousStop:note];

	cellStatus = kCellStatusSpinner;
	isFirstPredictionsFetch = YES;

	ButtonBarCell *cell = (ButtonBarCell *)note.object;

	CATransition *pushTransition = [CATransition animation];
	pushTransition.duration = 0.5;
	pushTransition.type = kCATransitionPush;
	pushTransition.subtype = kCATransitionFromLeft;
	pushTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	pushTransition.delegate = self;

	self.view.userInteractionEnabled = NO;
	self.navigationController.navigationBar.userInteractionEnabled = NO;

	[tableView.layer addAnimation:pushTransition forKey:nil];
	[stopTitleLabel.layer addAnimation:pushTransition forKey:nil];

	self.stop = cell.previousStop;

	[self setupInitialContents];

	[tableView reloadData];
	[timer fire];

}

- (void) goToNextStop:(NSNotification *)note {

	[super goToNextStop:note];

	isFirstPredictionsFetch = YES;
	cellStatus = kCellStatusSpinner;

	ButtonBarCell *cell = (ButtonBarCell *)note.object;

	CATransition *pushTransition = [CATransition animation];
	pushTransition.duration = 0.5;
	pushTransition.type = kCATransitionPush;
	pushTransition.subtype = kCATransitionFromRight;
	pushTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	pushTransition.delegate = self;

	self.view.userInteractionEnabled = NO;
	self.navigationController.navigationBar.userInteractionEnabled = NO;

	[tableView.layer addAnimation:pushTransition forKey:nil];

	CATransition *stopNameFadeTransition = [CATransition animation];
	stopNameFadeTransition.duration = 0.5;
	stopNameFadeTransition.type = kCATransitionFade;
	stopNameFadeTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

	[stopTitleLabel.layer addAnimation:pushTransition forKey:nil];

	self.stop = cell.nextStop;

	[self setupInitialContents];

	[tableView reloadData];
	[timer fire];

}

- (void) loadLiveRoute:(NSNotification *)note {

	ButtonBarCell *cell = (ButtonBarCell *)note.object;
	LiveRouteTVC *liveRouteTVC = [[LiveRouteTVC alloc] init];
	liveRouteTVC.direction = cell.direction;
	liveRouteTVC.startingStop = stop;

	[self.navigationController pushViewController:liveRouteTVC animated:YES];


}

#pragma mark -
#pragma mark Predictions

// submits a request to the PredictionsManager for predictions of the displayed routes. results will be sent to didReceivePredictions
- (void) requestPredictions {

	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	PredictionsManager *predictionsManager = appDelegate.predictionsManager;

	NSMutableArray *requests = [NSMutableArray array];

	// for bart, a single request contains just the stopTag and agencyShortTitle
	PredictionRequest *request = [[PredictionRequest alloc] init];

	request.agencyShortTitle = @"bart";
	request.stopTag = self.stop.tag;
	request.isMainRoute = NO;

	[requests addObject:request];

	// request predictions for the stops in the favorites screen
	[NSThread detachNewThreadSelector:@selector(requestPredictionsForRequests:) toTarget:predictionsManager withObject:requests];

	// [predictionsManager requestPredictionsForRequests:requests];
	NSLog(@"BartStopDetails: predictions requested"); /* DEBUG LOG */

}

// method called when PredictionsManager returns predictions. set the predictions variable in the favoritestops delegate and reload the tableview
- (void) didReceivePredictions:(NSDictionary *)_predictions {

	// show error message if there is one
	if ([_predictions objectForKey:@"error"] != nil) {

		cellStatus = kCellStatusInternetFail;

		NSError *error = [_predictions objectForKey:@"error"];

		NSLog(@"%d", [errors containsObject:error.userInfo]); /* DEBUG LOG */

		// only show the error if it hasn't been shown before
		if (![errors containsObject:error.userInfo]) {

			NSLog(@"BartStopDetails: %@", @"ERROR"); /* DEBUG LOG */
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"message"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alertView show];

		}
		// store the error in the errors array
		[errors addObject:error.userInfo];
		[tableView reloadData];
		return;

	} else {

		cellStatus = kCellStatusDefault;

		// FILTER PREDICTIONS FOR THIS STOP
		Prediction *newPrediction = [_predictions objectForKey:stop.tag];

		// view controllers need to be ready to receive predictions for any stop/agency. if there are non for this stop, do not proceed
		if (newPrediction == nil) {

			NSLog(@"BartStopDetails: IGNORED NON-THIS-STOP PREDICTIONS"); /* DEBUG LOG */
			return;
		}
		[predictions setObject:newPrediction forKey:stop.tag];

		// we've recieved predictions (grouped by route) for all the routes that serve this stop. we now have to rejigger the
		// table contents to reflect this new data b/c we can't know which directions for which routes will have predictions

		// but only the first time
		if (isFirstPredictionsFetch) {

			[self setupContentsBasedOnPredictions];
			isFirstPredictionsFetch = NO;

		}
		// every subsquent time, just add the predictions to the predictions dictionary and reload the table
		// unless it's bart, in which case, just do what you'd otherwise do, recreate the contents array from the predictions
		else [self.tableView reloadData];
	}
}

- (void) setupContentsBasedOnPredictions {

	// LIKE WITH NEXTBUS STOPS, WE WANT TO FIND OUT IF THERE ARE ANY DESTINATIONS IN THE PREDICTIONS THAT AREN'T ALREADY IN THE CONTENTS
	// IF THERE ARE ANY LEFTOVER PREDICTIONS, SAVE THEM TO A DICTIONARY
	NSMutableDictionary *leftoverDestinationArrivals = [[NSMutableDictionary alloc] init];

	Prediction *prediction = [predictions objectForKey:stop.tag];
	NSDictionary *arrivals = prediction.arrivals;

	NSArray *destinationTags = [prediction.arrivals allKeys];

	for (NSString *destinationTag in destinationTags) {

		[leftoverDestinationArrivals setObject:[arrivals objectForKey:destinationTag] forKey:destinationTag];

		// go through each section in the contents looking for this destination tag
		for (NSMutableArray *tableSection in contents)

			for (Destination * destination in tableSection)

				if ([destination.destinationStop.tag isEqualToString:destinationTag]) [leftoverDestinationArrivals removeObjectForKey:destinationTag];
	}
	NSLog(@"Leftover Destination Arrivals: %@", leftoverDestinationArrivals); /* DEBUG LOG */

	// THE DESTINATIONS IN THE LEFTOVER PREDICTIONS DICTIONARY ARE NON-STANDARD DESTINATIONS (E.G. 24TH ST, CONCORD, ETC.)
	// WE ONLY WANT TO ADD THEM IF THE FIRST ARRIVAL IS < 20 MINUTES AWAY.
	// SO, DON'T ADD ANY PREDICTIONS FROM THE DICTIONARY THAT DON'T MEET THIS CRITERION

	// create a direction object for each arrivals key
	for (NSString *arrivalsKey in [leftoverDestinationArrivals allKeys]) {

		NSArray *arrivals = [leftoverDestinationArrivals objectForKey:arrivalsKey];

		NSDictionary *firstArrivalDict = [arrivals objectAtIndex:0];

		int firstArrival = [[firstArrivalDict objectForKey:@"minutes"] intValue];

		// don't add this destination if it's first predictions is more then 20 minutes away
		if (firstArrival > 20) {

			NSLog(@"Destination not added b/c to far away: %@", arrivalsKey); /* DEBUG LOG */
			continue;
		}
		NSString *platformNumber = [firstArrivalDict objectForKey:@"platform"];

		int sectionIndex = [platforms indexOfObject:platformNumber];

		// CREATE THE PREDICTION OBJECT TO ADD TO THE CONTENTS

		Stop *destinationStop = [DataHelper stopWithTag:arrivalsKey inAgencyWithShortTitle:@"bart"];
		Destination *destinationToAdd = [[Destination alloc] initWithDestinationStop:destinationStop forStop:stop];

		[[contents objectAtIndex:sectionIndex] addObject:destinationToAdd];

		NSSortDescriptor *destinationTitleSorter = [[NSSortDescriptor alloc] initWithKey:@"destinationStop.title" ascending:YES];

		[[contents objectAtIndex:sectionIndex] sortUsingDescriptors:[NSMutableArray arrayWithObject:destinationTitleSorter]];


	}

	// NSLog(@"PREDICTIONS: %@", predictions); /* DEBUG LOG */

	[tableView reloadData];

}

#pragma mark -
#pragma mark Table

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	RowDivider *header = [[RowDivider alloc] initWithFrame:CGRectMake(0, 0, 320, kRowDividerHeight)];

	NSString *platformNumber = [platforms objectAtIndex:section];
	header.title = [NSString stringWithFormat:@"Platform %@", platformNumber];
	return(header);

}

- (UITableViewCell *) tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	int row = indexPath.row;
	int section = indexPath.section;

	// contents object
	id object = [[contents objectAtIndex:section] objectAtIndex:row];

	// BUTTON ROW
	if ([object isMemberOfClass:[NSNull class]]) {

		static NSString *ButtonBarCellIdentifier = @"ButtonBarCellIdentifier";

		ButtonBarCell *cell = (ButtonBarCell *)[tableView dequeueReusableCellWithIdentifier:ButtonBarCellIdentifier];

		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ButtonBarCell" owner:self options:nil];

			for (id object in nib)
				if ([object isKindOfClass:[ButtonBarCell class]]) {
					cell = (ButtonBarCell *)object;
					cell.selectionStyle = UITableViewCellSelectionStyleNone;
				}
		}
		cell.stop = stop;

		Destination *destination = (Destination *)[[contents objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
		cell.direction = destination.direction;

		[cell configureButtons];

		return(cell);
	}
	// DESTINATION ROW
	else if ([object isMemberOfClass:[Destination class]]) {

		static NSString *LineCellIdentifier = @"LineCellIdentifier";
		LineCell *cell = (LineCell *)[tableView dequeueReusableCellWithIdentifier:LineCellIdentifier];

		if (cell == nil) {

			cell = [[LineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LineCellIdentifier];
			cell.lineCellView = [[DestinationCellView alloc] init];
			[cell.contentView addSubview:cell.lineCellView];
			[cell.lineCellView release];
		}
		Destination *destination = (Destination *)object;

		DestinationCellView *destinationCellView = (DestinationCellView *)cell.lineCellView;

		// style the favorite button
		destinationCellView.stop = stop;
		[destinationCellView setDestination:destination];

		[destinationCellView setFavoriteStatus];        // sets the star image depending on whether that direction/stop combo is a favorite

		destinationCellView.majorTitle = destination.destinationStop.title;

		// all cell statuses are the same for every cell on the screen, except the PredictionFail status
		if ([[predictions objectForKey:stop.tag] isError]) [destinationCellView setCellStatus:kCellStatusPredictionFail withArrivals:nil];
		else {

			// temporary: find the arrivals for the given direction cell, if it exists
			NSArray *arrivals = [[[predictions objectForKey:stop.tag] arrivals] objectForKey:destination.destinationStop.tag];

			[destinationCellView setCellStatus:cellStatus withArrivals:arrivals];
		}
		return(cell);

	}
	return(nil);
}

#pragma mark -
#pragma mark Memory


@end
