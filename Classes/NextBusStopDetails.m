//
// NextBusStopDetails.m
// transporter
//
// Created by Ljuba Miljkovic on 4/26/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Direction.h"
#import "DirectionCellView.h"
#import "NextBusStopDetails.h"

@implementation NextBusStopDetails

@synthesize mainDirection;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[super viewDidLoad];

	NSString *agencyShortTitle = [[DataHelper agencyFromStop:stop] shortTitle];

	if ([agencyShortTitle isEqual:@"actransit"]) stopTitleImageView.image = [UIImage imageNamed:@"stop-name-background-actransit.png"];
	else stopTitleImageView.image = [UIImage imageNamed:@"stop-name-background-sfmuni.png"];
	// SETUP THE SWITCH DIRECTIONS BUTTON
	UIBarButtonItem *switchDirectionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"switch-directions.png"]
						   style:UIBarButtonItemStylePlain
						   target:self
						   action:@selector(switchDirections)];
	self.navigationItem.rightBarButtonItem = switchDirectionsButton;
	[switchDirectionsButton release];

	// SETUP THE CONTENTS ARRAY WITH SHOW=TRUE DIRECTIONS AND FAVORITED DIRECTIONS
	[self setupInitialContents];
}

// called whenever a new stop is selected in the stopDetails screen (on viewDidLoad, nextStop, prevStop, switchDirections)
- (void) setupInitialContents {

	[super setupInitialContents];

	// ACTIVATE "SWITCH DIRECTIONS" BUTTON AS NEEDED
	if (stop.oppositeStop == nil) self.navigationItem.rightBarButtonItem.enabled = NO;
	else self.navigationItem.rightBarButtonItem.enabled = YES;
	// FORMAT STOP TITLE
	NSMutableString *stopTitle = [NSMutableString stringWithString:stop.title];
	CGSize titleSize = [stopTitle sizeWithFont:stopTitleLabel.font];

	NSRange ampersandLocation = [stop.title rangeOfString:@"&"];

	// if the stop name needs 2 lines, add a new line character after the separator character (&,@)
	if ( (titleSize.width > 300)&&(ampersandLocation.length != 0) )	[stopTitle insertString:@"\n" atIndex:ampersandLocation.location];
	self.stopTitleLabel.text = stopTitle;

	if (mainDirection != nil) {

		// add the main direction to the contents as arrays
		[self.contents addObject:[NSMutableArray arrayWithObject:mainDirection]];

		// save the mainDirection to userDefaults so we can restore the path of view controllers to the NextBusStopDetailsVC
		[DataHelper saveDirectionIDInUserDefaults:mainDirection forKey:@"mainDirectionURIData"];

	}
	// an array of directions that serve this stop
	NSMutableArray *otherDirections = [[NSMutableArray alloc] initWithArray:[stop.directions allObjects]];

	// only keep the directions that serve this stop that aren't the mainDirection and show=true
	NSPredicate *showTruePredicate = [NSPredicate predicateWithFormat:@"show == %@", [NSNumber numberWithBool:YES]];
	[otherDirections filterUsingPredicate:showTruePredicate];

	// remove the mainDirections from this array if it exists
	for (Direction *direction in otherDirections)

		if ([direction.route.tag isEqualToString:mainDirection.route.tag]&&
		    [direction.name isEqualToString:mainDirection.name]&&
		    [direction.title isEqualToString:mainDirection.title]) {

			[otherDirections removeObject:direction];
			NSLog(@"DIRECTION TO REMOVE FROM OTHER DIRECTIONS: %@ %@", direction.route.tag, direction.name); /* DEBUG LOG */
			break;

		}
	// sorting will happen at the end of this method

	[self.contents addObject:[NSMutableArray arrayWithArray:otherDirections]];
	[otherDirections release];

	// INSERT ANY FAVORITED DESTINATIONS THAT AREN'T ALREADY THERE

	// load favorites for this stop
	NSMutableArray *favorites = [[NSMutableArray alloc] initWithArray:[FavoritesManager getFavorites]];

	NSString *agencyShortTitle = [[DataHelper agencyFromStop:stop] shortTitle];
	NSPredicate *agencyFilter = [NSPredicate predicateWithFormat:@"agencyShortTitle == %@", agencyShortTitle];
	NSPredicate *stopFilter = [NSPredicate predicateWithFormat:@"tag == %@", stop.tag];

	[favorites filterUsingPredicate:agencyFilter];
	[favorites filterUsingPredicate:stopFilter];

	NSMutableArray *lineDictsToAdd = [[NSMutableArray alloc] init];

	for (NSDictionary *favorite in favorites) {

		NSArray *lines = [favorite objectForKey:@"lines"];

		for (NSDictionary *line in lines) {

			[lineDictsToAdd addObject:line];

			NSString *routeTag = [line objectForKey:@"routeTag"];
			NSString *directionName = [line objectForKey:@"name"];
			NSString *directionTitle = [line objectForKey:@"title"];

			for (NSArray *sectionArray in contents)

				for (Direction * direction in sectionArray)

					if ([routeTag isEqualToString:direction.route.tag]&&
					    [directionName isEqualToString:direction.name]&&
					    [directionTitle isEqualToString:direction.title]) [lineDictsToAdd removeObject:line];
		}
	}

	// add the directions to the contents
	for (NSDictionary *line in lineDictsToAdd) {

		NSLog(@"NON-DEFAULT FAVORITE LINE ADDED: %@", line); /* DEBUG LOG */

		NSString *routeTag = [line objectForKey:@"routeTag"];
		NSString *dirTag = [[line objectForKey:@"matchingDirTags"] objectAtIndex:0];
		Route *route = [DataHelper routeWithTag:routeTag inAgencyWithShortTitle:agencyShortTitle];

		Direction *direction = [DataHelper directionWithTag:dirTag inRoute:route];

		[[contents lastObject] addObject:direction];

	}
	[favorites release];
	[lineDictsToAdd release];

	// sort directions by the sortOrder of their routes
	NSSortDescriptor *routeSorter = [[NSSortDescriptor alloc] initWithKey:@"route.sortOrder" ascending:YES];
	NSSortDescriptor *directionTitleSorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[[contents lastObject] sortUsingDescriptors:[NSArray arrayWithObjects:routeSorter, directionTitleSorter, nil]];
	[routeSorter release];
	[directionTitleSorter release];

}

#pragma mark -
#pragma mark Navigation Buttons

- (void) goToPreviousStop:(NSNotification *)note {

	[super goToPreviousStop:note];

	cellStatus = kCellStatusSpinner;
	isFirstPredictionsFetch = YES;

	ButtonBarCell *cell = (ButtonBarCell *)note.object;

	// if you don't want the previous stop of the main direction, the upcoming screen shouldn't have a main direction
	if (![mainDirection isEqual:cell.direction]) mainDirection = nil;
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

	// if you don't want the next stop of the main direction, the upcoming screen shouldn't have a main direction
	if (![mainDirection isEqual:cell.direction]) mainDirection = nil;
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
// flip directions
- (void) switchDirections {
	NSLog(@"STOPDETAILSVC: Reverse Stop: %@", stop.oppositeStop.title); /* DEBUG LOG */

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
	 forView:tableView cache:YES];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	self.navigationController.navigationBar.userInteractionEnabled = NO;
	self.view.userInteractionEnabled = NO;

	[UIView setAnimationDidStopSelector:@selector(enableUserInteraction)];

	[UIView commitAnimations];

	cellStatus = kCellStatusSpinner;

	self.stop = stop.oppositeStop;
	mainDirection = nil;

	isFirstPredictionsFetch = YES;

	[self setupInitialContents];

	[tableView reloadData];
	[self requestPredictions];

}

#pragma mark -
#pragma mark Prediction Handling

// submits a request to the PredictionsManager for predictions of the displayed routes. results will be sent to didReceivePredictions
- (void) requestPredictions {

	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	PredictionsManager *predictionsManager = appDelegate.predictionsManager;

	NSMutableArray *requests = [NSMutableArray array];

	NSArray *routes = [DataHelper uniqueRoutesForStop:self.stop];

	for (Route *route in routes) {

		PredictionRequest *request = [[PredictionRequest alloc] init];

		request.agencyShortTitle = [[DataHelper agencyFromStop:stop] shortTitle];
		request.route = route;
		request.stopTag = self.stop.tag;

		if ([route isEqual:mainDirection.route]) {
			request.isMainRoute = YES;
			[requests insertObject:request atIndex:0];
		} else {
			request.isMainRoute = NO;
			[requests addObject:request];
		}
		[request release];
	}
	// request predictions for the stops in the favorites screen
	[NSThread detachNewThreadSelector:@selector(requestPredictionsForRequests:) toTarget:predictionsManager withObject:requests];

	// [predictionsManager requestPredictionsForRequests:requests];
	NSLog(@"NextBusStopDetails: predictions requested"); /* DEBUG LOG */
	NSLog(@"%@", requests); /* DEBUG LOG */

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

			NSLog(@"StopDetailsVC: %@", @"ERROR"); /* DEBUG LOG */
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error.userInfo objectForKey:@"message"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alertView show];
			[alertView release];

		}
		// store the error in the errors array
		[errors addObject:error.userInfo];
		[self.tableView reloadData];
		return;

	} else {

		for (Prediction *prediction in [_predictions allValues]) NSLog(@"INCOMING ARRIVALS: %@", prediction.arrivals);
		// FILTER PREDICTIONS FOR THIS STOP
		NSDictionary *filteredPredictions = [PredictionsManager filterPredictions:_predictions ForStop:stop];

		if (filteredPredictions == nil) {

			NSLog(@"NextBusStopDetails: IGNORED NON-THIS-STOP PREDICTIONS"); /* DEBUG LOG */
			return;

		}
		[predictions addEntriesFromDictionary:filteredPredictions];

		// the number of rows currently in the contents array
		NSMutableDictionary *routes = [[NSMutableDictionary alloc] init];

		for (NSArray *sectionArray in contents) {
			for (id rowItem in sectionArray)

				if ([rowItem isMemberOfClass:[Direction class]]) {

					Direction *direction = (Direction *)rowItem;

					[routes setObject:direction.route forKey:direction.route.tag];

				}
		}
		int numberOfPredictions = [predictions count];
		int numberOfRoutes = [routes count];

		// only change the global cellStatus variable if every route has a prediction object (there could be more)
		if (numberOfPredictions >= numberOfRoutes) cellStatus = kCellStatusDefault;
		[routes release];

		// we've recieved predictions (grouped by route) for all the routes that serve this stop. we now have to rejigger the
		// table contents to reflect this new data b/c we can't know which directions for which routes will have predictions

		if (isFirstPredictionsFetch) {
			[self setupContentsBasedOnPredictions];
			isFirstPredictionsFetch = NO;
		} else [tableView reloadData];
	}
}

- (void) setupContentsBasedOnPredictions {

	// COMPARE THE DIRECTIONS OF THE ARRIVALS FOR EACH PREDICTION TO THE DIRECTIONS IN THE CONTENTS ARRAY
	// (COMPARE ROUTE TAG, DIRECTION NAME, DIRECTION TITLE)
	// 1. IF CONTENTS CONTAINS PREDICTION DIRECTION, CHECK DIR TAG.
	// IF SAME, DO NOTHING. IF NOT, REPLACE DIRECTION IN CONTENTS WITH DIRECTION OF NEW TAG
	// 2. IF NOT, ADD THE DIRECTION TO THE CONTENTS, ADD ROW TO TABLE

	// A dictionary of prediction key that link to an array of arrival keys.
	// This items are added and removed to it in the loop below such that at the end you have a dictionary with the prediction and arrivals
	// keys for the lines that have predictions but aren't already in the conents array. That way, you can add those rows in the loop that follows
	NSMutableDictionary *leftoverPredictionKeys = [[NSMutableDictionary alloc] init];

	// Go through the arrivals keys (direction tags) of each prediction and remove them if that direction is in the contents
	// At the end, you should be left with predictions with arrivals keys that aren't in the contents
	// INITIALIZE THE LEFTOVER PREDICTIONS ARRAY WITH ALL OF THE PREDICTIONS AND ARRIVALS

	NSMutableDictionary *directionSwitches = [[NSMutableDictionary alloc] init];

	for (NSString *predictionKey in [predictions allKeys]) {

		Prediction *prediction = [predictions objectForKey:predictionKey];
		[leftoverPredictionKeys setObject:[NSMutableArray array] forKey:predictionKey];

		NSLog(@"PREDICTION ROUTE: %@", prediction.route.tag); /* DEBUG LOG */

		NSArray *arrivalsKeys = [prediction.arrivals allKeys];

		for (NSString *arrivalsKey in arrivalsKeys) {

			[[leftoverPredictionKeys objectForKey:predictionKey] addObject:arrivalsKey];

			NSLog(@"  KEY: %@", arrivalsKey); /* DEBUG LOG */

			for (NSMutableArray *sectionArray in contents) {

				for (Direction *direction in sectionArray)

					if ([[PredictionsManager arrivalsKeyForDirection:direction] isEqualToString:arrivalsKey]) {

						NSArray *arrivals = [prediction.arrivals objectForKey:arrivalsKey];

						NSString *arrivalDirectionTag = [[arrivals objectAtIndex:0] objectForKey:@"dirTag"];

						if (![direction.tag isEqualToString:arrivalDirectionTag]&&
						    (arrivalDirectionTag != @"")&&
						    [direction.route.tag isEqualToString:prediction.route.tag]) {

							[directionSwitches setObject:direction forKey:arrivalDirectionTag];

							NSLog(@"arrivalDirectionTag: %@", arrivalDirectionTag);
							NSLog(@"direction Tag:       %@", direction.tag);

						}
						[[leftoverPredictionKeys objectForKey:predictionKey] removeObject:arrivalsKey];

					}
			}
		}

		if ([[leftoverPredictionKeys objectForKey:predictionKey] count] == 0) [leftoverPredictionKeys removeObjectForKey:predictionKey];
	}

	// switch out any directions that don't match the arrival direction tag. This can happen because predictions come in for all directions of a route.
	// they don't always match what you expect, or the direction you saved as a favorite
	for (NSString *arrivalDirTag in [directionSwitches allKeys]) {

		Direction *oldDirection = [directionSwitches objectForKey:arrivalDirTag];
		Direction *arrivalDirection = [DataHelper directionWithTag:arrivalDirTag inRoute:oldDirection.route];

		int sectionIndex = -1;
		int directionIndex = -1;

		for (NSMutableArray *sectionArray in contents)

			if ([sectionArray containsObject:oldDirection]) {
				sectionIndex = [contents indexOfObject:sectionArray];
				directionIndex = [sectionArray indexOfObjectIdenticalTo:oldDirection];
			}

		if ( (sectionIndex > -1)&&(directionIndex > -1) ) {

			[(NSMutableArray *)[contents objectAtIndex:sectionIndex] replaceObjectAtIndex:directionIndex withObject:arrivalDirection];
			NSLog(@"direction Switched from: %@ to: %@", oldDirection.tag, arrivalDirection.tag);

		}
	}
	[directionSwitches release];

	NSLog(@"LEFTOVERS: %@", leftoverPredictionKeys); /* DEBUG LOG */

	// WE NOW HAVE AN ARRAY OF PREDICTIONS WITH ARRIVALS DIRECTIONS THAT AREN'T IN CONTENTS ARRAY (leftoverPredictionsArray)
	// WE WANT TO ADD THOSE DIRECTIONS TO THE CONTENTS ARRAY
	// WE NEVER ADD DIRECTION ROWS TO THE MAIN-DIRECTION SECTION. THE LAST SECTION WILL ALWAYS BE THE CORRET ONE TO ADD DIRECTIONS TO

	NSMutableArray *lastSection = [contents lastObject];

	// create a direction object for each prediction key
	for (NSString *predictionKey in leftoverPredictionKeys) {

		Route *route = [[predictions objectForKey:predictionKey] route];
		NSDictionary *arrivalsDict = [[predictions objectForKey:predictionKey] arrivals];

		NSLog(@"ROUTE: %@", route); /* DEBUG LOG */

		NSArray *arrivalsKeys = [leftoverPredictionKeys objectForKey:predictionKey];

		for (NSString *arrivalsKey in arrivalsKeys) {

			NSArray *arrivalsArray = [arrivalsDict objectForKey:arrivalsKey];

			if ([arrivalsArray count] > 0) {

				NSDictionary *firstArrival = [arrivalsArray objectAtIndex:0];

				NSString *dirTag = [firstArrival objectForKey:@"dirTag"];
				NSLog(@"DIRTAG: %@", dirTag); /* DEBUG LOG */
				Direction *directionToAdd = [DataHelper directionWithTag:dirTag inRoute:route];
				[lastSection addObject:directionToAdd];

			}
		}
	}
	NSSortDescriptor *routeSorter = [[NSSortDescriptor alloc] initWithKey:@"route.sortOrder" ascending:YES];
	NSSortDescriptor *directionTitleSorter = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[lastSection sortUsingDescriptors:[NSArray arrayWithObjects:routeSorter, directionTitleSorter, nil]];
	[routeSorter release];
	[directionTitleSorter release];

	[leftoverPredictionKeys release];

	// NSLog(@"PREDICTIONS: %@", predictions); /* DEBUG LOG */

	[tableView reloadData];

	NSLog(@"----CONTENTS: %@", contents);
}

#pragma mark -
#pragma mark TableView Methods

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	if ( (section == 1)&&([[contents objectAtIndex:section] count] > 0) ) return(kRowDividerHeight);
	return(0);

}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	// only show the "other lines at this stop" header if there are rows in the second section
	if ( (section == 1)&&([[contents objectAtIndex:section] count] > 0) ) {
		RowDivider *header = [[[RowDivider alloc] initWithFrame:CGRectMake(0, 0, 320, kRowDividerHeight)] autorelease];
		header.title = @"Other Lines at this Stop";
		return(header);
	}
	return(nil);

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
		cell.direction = [[contents objectAtIndex:section] objectAtIndex:row - 1];

		[cell configureButtons];

		return(cell);
	}
	// DIRECTION ROW
	else if ([object isMemberOfClass:[Direction class]]) {

		static NSString *LineCellIdentifier = @"LineCellIdentifier";
		LineCell *cell = (LineCell *)[tableView dequeueReusableCellWithIdentifier:LineCellIdentifier];

		if (cell == nil) {

			cell = [[[LineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LineCellIdentifier] autorelease];
			cell.lineCellView = [[[DirectionCellView alloc] init] autorelease];
			[cell.contentView addSubview:cell.lineCellView];
		}
		Direction *direction = (Direction *)object;

		DirectionCellView *directionCellView = (DirectionCellView *)cell.lineCellView;

		// style the favorite button
		directionCellView.stop = stop;
		directionCellView.direction = direction;

		[directionCellView setFavoriteStatus];  // sets the star image depending on whether that direction/stop combo is a favorite

		directionCellView.majorTitle = [NSString stringWithFormat:@"%@ %@", direction.route.tag, direction.name];
		directionCellView.directionTitleLabel.text = [NSString stringWithFormat:@"→ %@", direction.title];

		NSString *predictionKey = [PredictionsManager predictionKeyFromAgencyShortTitle:direction.route.agency.shortTitle routeTag:direction.route.tag stopTag:stop.tag];

		// all cell statuses are the same for every cell on the screen, except the PredictionFail status
		if ([[predictions objectForKey:predictionKey] isError])	[directionCellView setCellStatus:kCellStatusPredictionFail withArrivals:nil];
		else {
			NSArray *arrivals = [[[predictions objectForKey:predictionKey] arrivals] objectForKey:[PredictionsManager arrivalsKeyForDirection:direction]];

			NSLog(@"ARRIVALS:%@", arrivals); /* DEBUG LOG */

			[directionCellView setCellStatus:cellStatus withArrivals:arrivals];
		}
		return(cell);

	}
	return(nil);
}

#pragma mark -
#pragma mark Memory

- (void) dealloc {
	[super dealloc];
}

@end
