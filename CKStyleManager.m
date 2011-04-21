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
		CKStyleManager* manager = [[CKStyleManager alloc]init];
		
		//Sample style addition for object of type MyController with property name = theController :
		/*
		 NSMutableDictionary* style = [NSMutableDictionary dictionary];
		NSMutableDictionary* backgroundStyle = [NSMutableDictionary dictionary];
		[backgroundStyle setObject:[UIColor redColor] forKey:CKStyleColor];
		[style setObject:backgroundStyle forKey:CKStyleBackgroundStyle];
		[manager setStyle:style forKey:@"MyController,name=\"theController\"";
		 */
		 
		
		CKStyleManagerDefault = manager;
	}
	return CKStyleManagerDefault;
}

- (void)setStyle:(NSDictionary*)style forKey:(NSString*)key{
	[_styles setStyle:style forKey:key];
}

- (NSDictionary*)styleForObject:(id)object  propertyName:(NSString*)propertyName{
	return [_styles styleForObject:object propertyName:propertyName];
}


- (id) initWithCoder:(NSCoder *)aDecoder {
	NSAssert([aDecoder allowsKeyedCoding],@"CKStyleManager does not support sequential archiving.");
    self = [self init];
    if (self) {
		[_styles initWithCoder:aDecoder];
		[_styles initAfterLoading];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[_styles encodeWithCoder:aCoder];
}

@end
