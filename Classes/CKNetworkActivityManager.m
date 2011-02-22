//
//  CKNetworkActivityManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-22.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNetworkActivityManager.h"

@interface CKNetworkActivityManager ()
@property (nonatomic, retain) NSMutableSet *objects;
@end

static CKNetworkActivityManager* CKDefaultNetworkActivityManager = nil;
@implementation CKNetworkActivityManager
@synthesize objects;

+ (CKNetworkActivityManager*)defaultManager{
	if(CKDefaultNetworkActivityManager == nil){
		CKDefaultNetworkActivityManager = [[CKNetworkActivityManager alloc]init];
	}
	return CKDefaultNetworkActivityManager;
}

- (id)init{
	[super init];
	self.objects = [NSMutableArray array];
	return self;
}

- (void)dealloc{
	self.objects = nil;
	[super dealloc];
}

- (void)addNetworkActivityForObject:(id)object{
	if([self.objects count] == 0){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	[self.objects addObject:[NSValue valueWithNonretainedObject:object]];
	
	//NSLog(@"Network Activity Count = %d",[self.objects count]);
}

- (void)removeNetworkActivityForObject:(id)object{
	[self.objects removeObject:[NSValue valueWithNonretainedObject:object]];
	if([self.objects count] == 0){
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	
	//NSLog(@"Network Activity Count = %d",[self.objects count]);
}

- (NSString*)description{
	NSString* desc = [NSString stringWithFormat:@"CKNetworkActivityManager objects : {\n"];
	for(NSValue* object in objects){
		desc = [desc stringByAppendingFormat:@"%@\n",[[object nonretainedObjectValue] description]];
	}
	desc = [desc stringByAppendingFormat:@"}\n"];
	return desc;
}

@end
