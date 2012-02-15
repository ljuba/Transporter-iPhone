//
//  Update.h
//  transporter
//
//  Created by ben bloch on 9/8/10.
//  Copyright 2010 Ljuba Miljkovic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Update : NSObject {
	int version;
	NSDate *updateTime;
	NSURL *dataURL;
	NSURL *imagesURL;
}

@property (nonatomic, assign) int version;
@property (nonatomic, retain) NSDate *updateTime;
@property (nonatomic, retain) NSURL *dataURL;
@property (nonatomic, retain) NSURL *imagesURL;

@end
