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

@interface CKStyleManager()
@property (nonatomic,retain) NSMutableDictionary* styles;
@end

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
		
		//Register default styles
		[manager.styles setObject:[CKStandardCellControllerStyle defaultStyle]            forKey:@"CKStandardCellControllerDefaultStyle"];
		[manager.styles setObject:[CKStandardCellControllerStyle value1Style]             forKey:@"CKStandardCellControllerValue1Style"];
		[manager.styles setObject:[CKStandardCellControllerStyle value2Style]             forKey:@"CKStandardCellControllerValue2Style"];
		[manager.styles setObject:[CKStandardCellControllerStyle subtitleStyle]           forKey:@"CKStandardCellControllerSubtitleStyle"];
		[manager.styles setObject:[CKDocumentCollectionCellControllerStyle defaultStyle]  forKey:@"CKDocumentCollectionCellControllerDefaultStyle"];
		
		CKStyleManagerDefault = manager;
	}
	return CKStyleManagerDefault;
}

+ (void)setStyle:(id)style forKey:(NSString*)key{
	CKStyleManager* manager = [CKStyleManager defaultManager];
	[manager.styles setObject:style forKey:key];
}

+ (id)styleForKey:(NSString*)key{
	CKStyleManager* manager = [CKStyleManager defaultManager];
	return [manager.styles objectForKey:key];
}

@end
