//
//  PredictionsManagerDelegate.h
//  This defines the methods that any object must conform to to receive notification of new prediction results.
//
//  Created by Ljuba Miljkovic on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



@protocol PredictionsManagerDelegate <NSObject>

- (void)didReceivePredictions:(NSDictionary *)predictions;

@end

