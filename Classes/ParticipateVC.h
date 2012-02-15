//
//  ParticipateVC.h
//  transporter
//
//  Created by Ljuba Miljkovic on 11/1/11.
//  Copyright (c) 2011 Ljuba Miljkovic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface ParticipateVC : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (retain, nonatomic) IBOutlet UIButton *hideButton;
@property (retain, nonatomic) IBOutlet UIButton *signUpButton;

- (void)hideMessage;
- (void)whatAreYou;

@end

