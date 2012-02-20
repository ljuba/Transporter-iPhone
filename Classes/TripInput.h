//
// TripInput.h
// kronos
//
// Created by Ljuba Miljkovic on 3/11/10.
// Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripInput : UIViewController <UITextFieldDelegate> {

	UITextField *startField;
	UITextField *endField;
	UIButton *switchFieldsButton;

	UIButton *changeTimeButton;
	UIBarButtonItem *cancelButton;

}

@property (nonatomic, retain) IBOutlet UITextField *startField;
@property (nonatomic, retain) IBOutlet UITextField *endField;
@property (nonatomic, retain) IBOutlet UIButton *changeTimeButton;
@property (nonatomic, retain) IBOutlet UIButton *switchFieldsButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction) switchFieldsContents;

- (IBAction) clearFields;
- (IBAction) enableCancelButton;

@end
