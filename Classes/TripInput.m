//
//  TripInput.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TripInput.h"
#import "TripOverview.h"

@implementation TripInput

@synthesize startField, endField, changeTimeButton, switchFieldsButton, cancelButton;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	startField.delegate = self;
	endField.delegate = self;
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	//fixes blurry text bug to have the fields be 32px high
	startField.frame = CGRectMake(startField.frame.origin.x, startField.frame.origin.y, startField.frame.size.width, 32);
	endField.frame = CGRectMake(endField.frame.origin.x, endField.frame.origin.y, endField.frame.size.width, 32);
	
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	[startField becomeFirstResponder];	
}

//delegate method that responds to the "enter" keyboard button being hit
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	//if you hit "return" (i.e. "next") on the start field, move on to the next field
	if (textField.tag == 0) {
		[startField resignFirstResponder];
		[endField becomeFirstResponder];
		return YES;
	}
	else {
		[endField resignFirstResponder];
		
		NSArray *objects = [NSArray arrayWithObjects:startField.text, endField.text, nil];
		NSArray *keys = [NSArray arrayWithObjects:@"startAddress", @"endAddress", nil];
		NSDictionary *tripRequest = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

		TripOverview *tripOverview = [[TripOverview alloc] init];
		tripOverview.tripRequest = tripRequest;
		
		[self.navigationController pushViewController:tripOverview animated:YES];
		[tripOverview release];
		
		return YES;
	}
}

- (IBAction)clearFields {
	
	if ([startField isFirstResponder]) {
		[startField resignFirstResponder];
	}
	else {
		[endField resignFirstResponder];		
	}
	
	cancelButton.enabled = NO;
	startField.text = nil;
	endField.text = nil;

}

// Enables the "Cancel" button if either text field is first responder 
- (IBAction)enableCancelButton {
	cancelButton.enabled = YES;
	
}


// Switches the contents of the start and end fields
-(IBAction)switchFieldsContents {
	
	NSString *storedStartField = [[NSString alloc] initWithString:startField.text];
	startField.text = endField.text;
	endField.text = storedStartField;
	
	[storedStartField release];
	
	//switch which text field is first responder
	if ([startField isFirstResponder]) {
		[startField resignFirstResponder];
		[endField becomeFirstResponder];
	}
	else {
		[endField resignFirstResponder];
		[startField becomeFirstResponder];
	}
}



#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.startField = nil;
	self.endField = nil;
	self.changeTimeButton = nil;
	self.switchFieldsButton = nil;
	self.cancelButton = nil;
}


- (void)dealloc {
	
	[super dealloc];
}


@end
