//
//  CKAttribute.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKAttribute.h"
#import "CKItemAttributeReference.h"

@implementation CKAttribute

@dynamic name;
@dynamic value;
@dynamic createdAt;
@dynamic item;
@dynamic itemReferences;

- (NSString*)description{
	return [NSString stringWithFormat:@"CKAttribute<%p> value:%@ References:%@",self,self.name,self.itemReferences];
}

- (NSArray*)items{
	NSMutableArray* array = [NSMutableArray array];
	for(CKItemAttributeReference* ref in self.itemReferences){
		[array addObject:ref.item];
	}
	return array;
}

@end

