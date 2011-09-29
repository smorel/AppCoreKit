//
//  CKDocument.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocument.h"

@interface CKDocument()
@property (nonatomic,retain) NSMutableDictionary* objects;
//@property (nonatomic,retain) NSMutableDictionary* retainCounts;
@end

@implementation CKDocument
@synthesize objects = _objects;
//@synthesize retainCounts = _retainCounts;


+ (id)sharedDocument{
	static id CKDocumentSharedInstance = nil;
	if (CKDocumentSharedInstance == nil) {
		CKDocumentSharedInstance = [[[self class] alloc] init];
        [CKDocumentSharedInstance postInit];
	}
	return CKDocumentSharedInstance;
}

- (void)postInit{
    
}

- (id)init{
	[super init];
	self.objects = [NSMutableDictionary dictionary];
//	self.retainCounts = [NSMutableDictionary dictionary];
	return self;
}

- (void)dealloc{
	[_objects release];
//	[_retainCounts release];
	[super dealloc];
}

- (void)clear{
	for(id object in [_objects allValues]){
		if([object isKindOfClass:[CKDocumentCollection class]]){
			CKDocumentCollection* collection = (CKDocumentCollection*)object;
			[collection removeAllObjects];
		}
	}
}

- (void)removeCollectionForKey:(NSString*)key{
	[_objects removeObjectForKey:key];
}

- (void)setCollection:(CKDocumentCollection*)collection forKey:(NSString*)key{
	NSAssert([_objects objectForKey:key] == nil,@"The document already contains an object for key '%@'",key);
	[_objects setObject:collection forKey:key];
}

- (CKDocumentCollection*)collectionForKey:(NSString*)key{
	id object = [_objects objectForKey:key];
	NSAssert(object == nil || [object isKindOfClass:[CKDocumentCollection class]],@"The object at key '%@' is not a CKDocumentCollection");
	return (CKDocumentCollection*)object;
}

- (CKDocumentArray*)arrayWithFeedSource:(CKFeedSource*)source forKey:(NSString*)key{
	return [self arrayWithFeedSource:source withStorage:nil forKey:key];
}

- (CKDocumentArray*)arrayWithFeedSource:(CKFeedSource*)source withStorage:(id)storage forKey:(NSString*)key{
	NSAssert([_objects objectForKey:key] == nil,@"The document already contains an object for key '%@'",key);
	CKDocumentArray* array = [[[CKDocumentArray alloc]initWithFeedSource:source withStorage:storage]autorelease];
	[_objects setObject:array forKey:key];
	return array;
}

- (CKDocumentArray*)arrayWithStorage:(id)storage forKey:(NSString*)key{
	NSAssert([_objects objectForKey:key] == nil,@"The document already contains an object for key '%@'",key);
	CKDocumentArray* array = [[[CKDocumentArray alloc]initWithStorage:storage]autorelease];
	[_objects setObject:array forKey:key];
	return array;
}

- (CKDocumentArray*)arrayWithFeedSource:(CKFeedSource*)source withStorage:(id)storage autoSave:(BOOL)autoSave forKey:(NSString*)key{
	CKDocumentArray* ar = [self arrayWithFeedSource:source withStorage:storage forKey:key];
	ar.autosave = autoSave;
	return ar;
}

- (CKDocumentArray*)arrayWithStorage:(id)storage autoSave:(BOOL)autoSave forKey:(NSString*)key{
	CKDocumentArray* ar = [self arrayWithStorage:storage forKey:key];
	ar.autosave = autoSave;
	return ar;	
}

- (CKDocumentArray*)arrayForKey:(NSString*)key{
	NSAssert([_objects objectForKey:key] == nil,@"The document already contains an object for key '%@'",key);
	CKDocumentArray* array = [[[CKDocumentArray alloc]init]autorelease];
	[_objects setObject:array forKey:key];
	return array;
}

@end
