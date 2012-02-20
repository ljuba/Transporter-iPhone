//
// LMTableView.m
// transporter
//
// Created by apple on 6/9/10.
// Copyright 2010 Ljuba Miljkovic. All rights reserved.
//

#import "LinesTableView.h"

@implementation LinesTableView

// this method is the only difference from UITableView. It allows buttons to show that they are activated as soon as they are touched, without having to wait.
- (BOOL) touchesShouldCancelInContentView:(UIView *)view
{
	return(YES);
}

@end
