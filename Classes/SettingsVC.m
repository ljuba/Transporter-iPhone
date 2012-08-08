//
// SettingsVC.m
// kronos
//
// Created by Ljuba Miljkovic on 4/11/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsVC.h"

@implementation SettingsVC

- (void) viewDidLoad {

	[super viewDidLoad];

	if ([MFMailComposeViewController canSendMail]) {
		// [self createBugReport];
	}
}

- (IBAction) createBugReport {

	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:@"Bug Report"];
	[controller setToRecipients:@[@"ljuba.miljkovic@gmail.com"]];
	[self presentModalViewController:controller animated:YES];

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}

- (void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload {
	[super viewDidUnload];
}


@end
