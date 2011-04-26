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
#import "CKUITableViewCell+Style.h"

#import "CJSONDeserializer.h"

static CKStyleManager* CKStyleManagerDefault = nil;
@implementation CKStyleManager
@synthesize styles = _styles;

- (void)dealloc{
	[_styles release];
	[super dealloc];
}

- (id)init{
	[super init];
	self.styles = [NSMutableDictionary dictionary];
	return self;
}

+ (CKStyleManager*)defaultManager{
	if(CKStyleManagerDefault == nil){
		CKStyleManagerDefault = [[CKStyleManager alloc]init];
	}
	return CKStyleManagerDefault;
}

- (void)setStyle:(NSMutableDictionary*)style forKey:(NSString*)key{
	[_styles setStyle:style forKey:key];
}

- (NSMutableDictionary*)styleForObject:(id)object  propertyName:(NSString*)propertyName{
	return [_styles styleForObject:object propertyName:propertyName];
}

- (void)loadContentOfFileNamed:(NSString*)name{
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
	[self loadContentOfFile:path];
}

- (void)loadContentOfFile:(NSString*)path{
	NSData* data = [NSData dataWithContentsOfFile:path];
	NSError* error = nil;
	id responseValue = [[CJSONDeserializer deserializer] deserialize:data error:&error];
	NSAssert([responseValue isKindOfClass:[NSDictionary class]],@"invalid format in style file");
	self.styles = [NSMutableDictionary dictionaryWithDictionary:responseValue];
	[_styles initAfterLoading];
}

@end
