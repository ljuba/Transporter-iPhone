//
//  UpdateManager.m
//  transporter
//
//  Created by ben bloch on 9/8/10.
//  Copyright 2010 Ljuba Miljkovic. All rights reserved.
//

#import "UpdateManager.h"
#import "FavoritesManager.h"
#import "TouchXML.h"

@implementation UpdateManager

@synthesize dataUpdated;

- (id)init {
	if (!(self = [super init])){
		return nil;
	}
	
	return self;
}

- (void)checkForLocalUpdate {
	
	//current data version
	int dataVersion = [self dataVersion];
	
	//get version of data in the main bundle
	NSDictionary *updateInfo = [NSDictionary dictionaryWithContentsOfFile:
								[[NSBundle mainBundle] pathForResource:@"update" ofType:@"plist"]];
	
	int localDataVersion = [[updateInfo objectForKey:@"dataVersion"] intValue];
	
	
	NSLog(@"current data version: %d, local data version: %d", dataVersion, localDataVersion);
	
	//if the data was just updated, check that favorites still work
	if (dataVersion < localDataVersion) {
		
        dataUpdated = YES;
        
		NSLog(@"data just updated locally");
		
		[FavoritesManager checkExistanceOfFavorites];
		
		[self setDataVersionTo:localDataVersion];
		
		// The following addresses an issue where a favorite stop doesn't exist anymore after an update.
		// A crash could still occur if the user views the stop details of the non-existant stop, and restarts the app again.
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults removeObjectForKey:@"stopURIData"];
		[userDefaults removeObjectForKey:@"mainDirectionURIData"];
		[userDefaults removeObjectForKey:@"savedViewController"];
		[userDefaults removeObjectForKey:@"liveRouteDirectionURIData"];
		
	}
    else {
        dataUpdated = NO;
    }
	
}

- (void)setDataVersionTo:(int)dataVersion {
	
	// Look in Documents for an existing favorites file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *updatePath = [documentsDirectory stringByAppendingPathComponent:@"update.plist"];
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:updatePath];
	
	if (fileExists) {
		
		NSDictionary *updatePlist = [NSDictionary dictionaryWithContentsOfFile:updatePath];
		[updatePlist setValue:[NSNumber numberWithInt:dataVersion] forKey:@"dataVersion"];
		[updatePlist writeToFile:updatePath atomically:YES];
		
	}
	else {
		
		NSDictionary *updatePlist = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:dataVersion] forKey:@"dataVersion"];
	
		[updatePlist writeToFile:updatePath atomically:YES];
						
	}

}

// Get the active update, compare with current version
- (void)checkForRemoteUpdate {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"checking for remote update");
	
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"config.plist"];
    NSDictionary *configData = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
    
	NSString *urlString = [configData valueForKey:@"checkForUpdateURL"];
	
	NSLog(@"%@", urlString); /* DEBUG LOG */
	
	//have to replace the unicode character | with escape characters 
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	
	//get the contents of the URL
	NSError *error;
	CXMLDocument *updateDocument = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error] autorelease];
		
	[url release];
	
	if (error != nil) {
		
		NSLog(@"update check not working...");
		
	}
	
	//PARSE THE RETURNED PREDICTIONS XML FILE
	
	//the xml nodes that contain arrivals for a particular stop/route
	NSArray *updateNodes = [updateDocument nodesForXPath:@"/update" error:nil];
	
	CXMLElement *updateElement = [updateNodes objectAtIndex:0];
	
	int activeDataVersion = [[[updateElement attributeForName:@"version"] stringValue] intValue];
	
	if (activeDataVersion > [self dataVersion]) {
		
		NSLog(@"Time to download some data");
		
		CXMLElement *dataElement = [[updateElement nodesForXPath:@"data" error:nil] objectAtIndex:0];
		NSString *dataURLString = [[dataElement attributeForName:@"resource"] stringValue];
		NSURL *dataURL = [[NSURL alloc] initWithString:dataURLString];
		
		NSLog(@"%@", dataURLString);
		
		CXMLElement *imagesElement = [[updateElement nodesForXPath:@"images" error:nil] objectAtIndex:0];
		NSString *imagesURLString = [[imagesElement attributeForName:@"resource"] stringValue];
		NSURL *imagesURL = [[NSURL alloc] initWithString:imagesURLString];
		
		NSLog(@"%@", imagesURLString);
		
		Update *update = [[Update alloc] init];
		update.version = activeDataVersion;
		update.dataURL = dataURL;
		update.imagesURL = imagesURL;
		
		[dataURL release];
		[imagesURL release];
		
		[self downloadUpdate:update];
		
		[update release];
	}
	else {
		NSLog(@"You have the latest version of the data");
	}

	[pool drain];
	
}

#pragma mark -
#pragma mark Downloading Update	

// Download the resources required to apply the update
- (void)downloadUpdate:(Update *)update {
	
	//NSURLRequest *dataRequest = [[NSURLRequest alloc] initWithURL:update.dataURL 
	//												  cachePolicy:NSURLRequestUseProtocolCachePolicy 
	//												  timeoutInterval:60.0];
	
	//NSData *updateData = [NSURLConnection sendSynchronousRequest:dataRequest returningResponse:nil error:nil];
	
	

}

#pragma mark -
#pragma mark Applying Update

// Update the data for the application
- (void)applyUpdate:(Update *)update {
	NSLog(@"applying update");
}


// Fetch current data version number
- (int)dataVersion {
	
	int dataVersion;
	
	// Look in Documents for an existing favorites file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *updatePath = [documentsDirectory stringByAppendingPathComponent:@"update.plist"];
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:updatePath];
	
	if (fileExists) {
		
		NSDictionary *updatePlist = [NSDictionary dictionaryWithContentsOfFile:updatePath];
		dataVersion = [[updatePlist objectForKey:@"dataVersion"] intValue];

	}
	else {
		
		dataVersion = 0;
		
	}

	return dataVersion;
	
	
}


@end
