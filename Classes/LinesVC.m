//
//  LinesVC.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LinesVC.h"
#import "acTransitDelegate.h"
#import "sfMuniDelegate.h"
#import "bartDelegate.h"
#import "kronosAppDelegate.h"
#import "DirectionsVC.h"
#import "StopsTVC.h"
#import "BartStopDetails.h"
#import "FlurryAnalytics.h"

@implementation LinesVC

@synthesize segmentedControl, tableView, transitDelegate, locationManager;

- (void)viewDidLoad {
	
	NSLog(@"LINESVC: %@", @"VIEW DID LOAD"); /* DEBUG LOG */
		
	//tableViewSettings
	tableView.showsVerticalScrollIndicator = NO;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"SF MUNI", @"BART", @"AC Transit", nil]];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl addTarget:self action:@selector(tapAgency) forControlEvents:UIControlEventValueChanged];	
	
	[segmentedControl setWidth:100.0 forSegmentAtIndex:0];
	[segmentedControl setWidth:98.0 forSegmentAtIndex:1];
	[segmentedControl setWidth:102.0 forSegmentAtIndex:2];

	self.navigationItem.titleView = segmentedControl;

	//setup core location and fetch locations while you're on this screen (for use later)
	locationManager = [[CLLocationManager alloc] init];
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	//setup notification observing for when a user taps on a route (for ac transit and muni) or station (for bart)
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(loadNextViewController:) name:@"routeSelected" object:nil];
	[notificationCenter addObserver:self selector:@selector(loadNextViewController:) name:@"stopSelected" object:nil];
	[notificationCenter addObserver:self selector:@selector(reloadSection0:) name:@"reloadSection0" object:nil];

	//sets the initial agency data depending on the segmented selected last
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	segmentedControl.selectedSegmentIndex = [userDefaults integerForKey:@"linesSegmentedControlIndex"];
	
	[self tapAgency];

	[FlurryAnalytics logEvent:@"Lines - viewDidLoad" withParameters:nil];
	
}


//respond to a notification that the table needs reloading
- (void)reloadSection0:(NSNotification *)note {
	
	//only reload the section if bart is selected
	if (segmentedControl.selectedSegmentIndex == 1) {
		[self.tableView reloadSections:	[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	}
	
}

//respond to a notification that a (for ac transit and muni) or station (for bart) was tapped  
- (void)loadNextViewController:(NSNotification *)note {
	
	//if an actransit/muni line was selected
	if (note.name == @"routeSelected") {
		
		self.navigationItem.title = @"Lines";
		
		Route *route = (Route *)[note.object selectedItem];
		
		[FlurryAnalytics logEvent:@"Lines - Route Selected" withParameters:[DataHelper dictionaryFromRoute:route]];
		
		DirectionsVC *directionsTableViewController = [[DirectionsVC alloc] init];
		directionsTableViewController.route = route;
			
		[self.navigationController pushViewController:directionsTableViewController animated:YES];
			
		[directionsTableViewController release];
		
	}
	else if (note.name == @"stopSelected") {
		
		self.navigationItem.title = @"Stops";
		
		Stop *stop = (Stop *)note.object ;
		
		[FlurryAnalytics logEvent:@"Lines - Stop Selected" withParameters:[DataHelper dictionaryFromStop:stop]];
		
		BartStopDetails *bartStopDetailsVC = [[BartStopDetails alloc] init];
		bartStopDetailsVC.stop = stop;

		[self.navigationController pushViewController:bartStopDetailsVC animated:YES];
		
		[bartStopDetailsVC release];
	}

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[locationManager stopUpdatingLocation];	
}


//responds to the tap of the agency segmented control and loads the appropriate agency data
- (void)tapAgency {

	//muni
	if (segmentedControl.selectedSegmentIndex == 0) {
		
		[segmentedControl setImage:[UIImage imageNamed:@"seg-muni-selected.png"] forSegmentAtIndex:0];
		[segmentedControl setImage:[UIImage imageNamed:@"seg-bart-deselected.png"] forSegmentAtIndex:1];
		[segmentedControl setImage:[UIImage imageNamed:@"seg-actransit-deselected.png"] forSegmentAtIndex:2];	
		
		self.transitDelegate = [[sfMuniDelegate alloc] initWithAgency:[self fetchAgencyData:@"sf-muni"]];
		
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;	
		tableView.backgroundColor = [UIColor colorWithWhite:0.369 alpha:1.0];
	}
	//bart
	else if (segmentedControl.selectedSegmentIndex == 1){
		
		[segmentedControl setImage:[UIImage imageNamed:@"seg-muni-deselected.png"] forSegmentAtIndex:0];
		[segmentedControl setImage:[UIImage imageNamed:@"seg-bart-selected.png"] forSegmentAtIndex:1];
		[segmentedControl setImage:[UIImage imageNamed:@"seg-actransit-deselected.png"] forSegmentAtIndex:2];
		
		self.transitDelegate = [[bartDelegate alloc] initWithAgency:[self fetchAgencyData:@"bart"]];
		locationManager.delegate = self.transitDelegate;
		
		tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		tableView.backgroundColor = [UIColor whiteColor];

	}
	//ac transit
	else {		
		[segmentedControl setImage:[UIImage imageNamed:@"seg-muni-deselected.png"] forSegmentAtIndex:0];
		[segmentedControl setImage:[UIImage imageNamed:@"seg-bart-deselected.png"] forSegmentAtIndex:1];
		[segmentedControl setImage:[UIImage imageNamed:@"seg-actransit-selected.png"] forSegmentAtIndex:2];
		
		self.transitDelegate = [[acTransitDelegate alloc] initWithAgency:[self fetchAgencyData:@"actransit"]];
		
		tableView.separatorStyle = UITableViewCellSeparatorStyleNone;	
		tableView.backgroundColor = [UIColor colorWithWhite:0.369 alpha:1.0];
	}

	//remember which agency is selected, so we can reload it next time
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:segmentedControl.selectedSegmentIndex forKey:@"linesSegmentedControlIndex"];

	self.tableView.dataSource = transitDelegate;
	self.tableView.delegate = transitDelegate;
	
	[tableView reloadData];
	
	NSIndexPath *topPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[tableView scrollToRowAtIndexPath:topPath atScrollPosition: UITableViewScrollPositionNone animated:NO];
	
}


//retreives an agency's data form core data and returns the Agency object
-(Agency *)fetchAgencyData:(NSString*)agency {
	
	//get the managedObjectContext from the appDelegate
	kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
	
	//Fetch all the agencies from the Core Data store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Agency" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shortTitle=%@",agency];
	[request setPredicate:predicate];
	
	//Receive the results
	NSError *error;
	NSMutableArray *agencies = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
	if (agencies == nil) {
		NSLog(@"Could not fetch agencies!");
		[request release];
		return nil;
	}
	[request release];
	
	Agency *fetchedAgency = [agencies objectAtIndex:0];
	[agencies release];
	
	return fetchedAgency;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.

	self.tableView = nil;

}


- (void)dealloc {
	
	//unregister the notification from the favorites delegates
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[segmentedControl release];
	[locationManager release];	//created in viewDidLoad
	[transitDelegate release];		//created in tapAgency, which is called in viewDidLoad
	
	[super dealloc];
}


@end
