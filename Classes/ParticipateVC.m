//
//  ParticipateVC.m
//  transporter
//
//  Created by Ljuba Miljkovic on 11/1/11.
//  Copyright (c) 2011 Ljuba Miljkovic. All rights reserved.
//

#import "ParticipateVC.h"
#import "kronosAppDelegate.h"
#import "FlurryAnalytics.h"

@implementation ParticipateVC

@synthesize hideButton;
@synthesize signUpButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [hideButton addTarget:self action:@selector(hideMessage) forControlEvents:UIControlEventTouchUpInside];
    [signUpButton addTarget:self action:@selector(whatAreYou) forControlEvents:UIControlEventTouchUpInside];

    
}


- (void)whatAreYou {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Get Involved. What are you?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Developer", @"Designer", @"Transit Nerd", @"Other", nil];
    
    kronosAppDelegate *appDelegate = (kronosAppDelegate *)[[UIApplication sharedApplication] delegate];    
    
    
    [actionSheet showFromTabBar:appDelegate.tabBarController.tabBar];
    
   
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *body;
    
    switch (buttonIndex) {
        case 0: //developer
            body = @"Hey, I'm a developer and I want to get involved in making Transporter even more awesome!";
            break;
        case 1: //designer
            body = @"Hey, I'm a designer and I want to get involved in making Transporter even more awesome!";            
            break;
        case 2: //transit nerd
            body = @"Hey, I'm a transit nerd and I want to get involved in making Transporter even more awesome!";
            break;
        case 3: //other
            body = @"Hey, I'm a __________ and I want to get involved in making Transporter even more awesome!";
            break;
        default:
            return;
    }
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:@"support@transporterapp.net"]];
	[controller setSubject:@"Transporter, heck ya!"];
	[controller setMessageBody:body isHTML:NO];
	[self presentModalViewController:controller animated:YES];
    
 
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
    
    if (result == MFMailComposeResultSent) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Great To Have You!" message:@"Hang tight for an invitation to the \n Bay Area Public Transit Future Group." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"declinedToParticipate"];
        [self.navigationController popToRootViewControllerAnimated:YES];  

    }

}



- (void)hideMessage {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"Are you sure you never want \n to see this message again?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"declinedToParticipate"];
        [self.navigationController popToRootViewControllerAnimated:YES];        
        
        [FlurryAnalytics logEvent:@"Hide Participation Message"];
    
    }
 
}

- (void)viewDidUnload
{
    [self setHideButton:nil];
    [self setSignUpButton:nil];
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
