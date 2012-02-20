//
// SettingsVC.h
// kronos
//
// Created by Ljuba Miljkovic on 4/11/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@interface SettingsVC : UIViewController <MFMailComposeViewControllerDelegate> {}

- (IBAction) createBugReport;

@end
