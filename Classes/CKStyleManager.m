//
//  CKStyleManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleManager.h"
#import "CKStandardCellController.h"
#import "CKDocumentCollectionCellController.h"

#import "CKStyles.h"
#import "CKUIView+Style.h"

#import "JSONKit.h"

@interface CKStyleManager()
@property (nonatomic,retain) NSMutableDictionary* styles;
@property (nonatomic,retain) NSMutableSet* loadedFiles;
@end

static CKStyleManager* CKStyleManagerDefault = nil;
@implementation CKStyleManager
@synthesize styles = _styles;
@synthesize loadedFiles = _loadedFiles;

- (void)dealloc{
	[_styles release];
	[super dealloc];
}

- (id)init{
	[super init];
	self.loadedFiles = [NSMutableSet set];
	return self;
}

+ (CKStyleManager*)defaultManager{
	if(CKStyleManagerDefault == nil){
		CKStyleManagerDefault = [[CKStyleManager alloc]init];
	}
	return CKStyleManagerDefault;
}

- (NSMutableDictionary*)styleForObject:(id)object  propertyName:(NSString*)propertyName{
	return [_styles styleForObject:object propertyName:propertyName];
}

- (void)loadContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
	[self loadContentOfFile:path];
}


- (BOOL)importContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
	return [self importContentOfFile:path];
}

- (BOOL)importContentOfFile:(NSString*)path{
	if([_loadedFiles containsObject:path])
		return NO;
	
    //Parse file with validation
	NSData* fileData = [NSData dataWithContentsOfFile:path];
	NSError* error = nil;
    id result = [fileData mutableObjectFromJSONDataWithParseOptions:JKParseOptionValidFlags error:&error];
	NSAssert(result != nil,@"invalid format in style file '%@'\nat line : '%@'\nwith error : '%@'",[path lastPathComponent],[[error userInfo]objectForKey:@"JKLineNumberKey"],
             [[error userInfo]objectForKey:@"NSLocalizedDescription"]);
	
    //Post process
    [_loadedFiles addObject:path];
	[result processImports];
	[_styles addEntriesFromDictionary:result];
	
	return YES;
}

- (void)loadContentOfFile:(NSString*)path{
	if (_styles == nil){
		self.styles = [NSMutableDictionary dictionary];
	}
	if([self importContentOfFile:path]){
		[_styles initAfterLoading];
		[_styles postInitAfterLoading];
	}
}

- (NSString*)description{
	return [_styles description];
}

@end
