//
//  CKDocumentFileStorage.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentFileStorage.h"


@implementation CKDocumentFileStorage
@synthesize path = _path;

- (void)dealloc{
	[_path release];
	[super dealloc];
}

- (id)initWithPath:(NSString*)thePath{
	[super init];
	self.path = thePath;
	return self;
}

- (BOOL)load:(CKDocumentCollection*)collection{
	if( [[NSFileManager defaultManager] fileExistsAtPath:_path] ){
		id result = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];
		[collection copy : result];
		return YES;
	}
	return NO;
}

- (BOOL)save:(CKDocumentCollection*)collection{
	return [NSKeyedArchiver archiveRootObject:collection toFile:_path];
}

@end
