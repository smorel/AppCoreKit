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

#import "CJSONDeserializer.h"

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


- (void)importContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
	[self importContentOfFile:path];
}

- (void)importContentOfFile:(NSString*)path{
	if([_loadedFiles containsObject:path])
		return;
	
	NSData* fileData = [NSData dataWithContentsOfFile:path];
	NSString* fileContentAsString = [[[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding]autorelease];

	//Removes comments
	NSScanner *s = [NSScanner scannerWithString:[fileContentAsString copy]];
	while (![s isAtEnd]) {
		NSString *text = @"";
		[s scanUpToString:@"/*" intoString:NULL];
		[s scanUpToString:@"*/" intoString:&text];
		fileContentAsString = [fileContentAsString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@*/", text] withString:@""];
	}
	
	NSData* dataToParse = [fileContentAsString dataUsingEncoding:NSUTF8StringEncoding];
	
	NSError* error = nil;
	id responseValue = [[CJSONDeserializer deserializer] deserialize:dataToParse error:&error];
	NSAssert([responseValue isKindOfClass:[NSDictionary class]],@"invalid format in style file");
	[_loadedFiles addObject:path];
	
	NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:responseValue];
	[result processImports];
	[_styles addEntriesFromDictionary:result];
}

- (void)loadContentOfFile:(NSString*)path{
	self.styles = [NSMutableDictionary dictionary];
	[self importContentOfFile:path];
	[_styles initAfterLoading];
	[_styles postInitAfterLoading];
}

- (NSString*)description{
	return [_styles description];
}

@end
