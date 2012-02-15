//
//  UpdateManager.h
//  transporter
//
//  Created by ben bloch on 9/8/10.
//  Copyright 2010 Ljuba Miljkovic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Update.h"

@interface UpdateManager : NSObject {
	int version;
    
    BOOL dataUpdated;
}

@property (nonatomic, readonly) BOOL dataUpdated;

- (void)checkForRemoteUpdate;
- (void)checkForLocalUpdate;
- (void)setDataVersionTo:(int)dataVersion;

- (void)downloadUpdate:(Update *)update;

- (void)applyUpdate:(Update *)update;
- (int)dataVersion;
- (BOOL) dataUpdated;

@end
