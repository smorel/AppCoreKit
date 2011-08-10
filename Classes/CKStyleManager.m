//
//  CKStyleManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleManager.h"

static CKStyleManager* CKStyleManagerDefault = nil;

@implementation CKStyleManager

+ (CKStyleManager*)defaultManager{
	if(CKStyleManagerDefault == nil){
		CKStyleManagerDefault = [[CKStyleManager alloc]init];
	}
	return CKStyleManagerDefault;
}

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
	return [self dictionaryForObject:object propertyName:propertyName];
}

- (void)loadContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
    NSLog(@"loadContentOfFileNamed %@ with path %@",name,path);
	[self loadContentOfFile:path];
}


- (BOOL)importContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
    NSLog(@"loadContentOfFileNamed %@ with path %@",name,path);
	return [self appendContentOfFile:path];
}

@end


@implementation NSMutableDictionary (CKStyleManager)

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
    return [self dictionaryForObject:object propertyName:propertyName];
}

@end