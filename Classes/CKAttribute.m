//
//  CKAttribute.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKAttribute.h"

@implementation CKAttribute

@dynamic name;
@dynamic value;
@dynamic createdAt;
@dynamic item;
@dynamic items;

- (NSString*)description{
	return [NSString stringWithFormat:@"CKAttribute<%p> value:%@ items:%@",self,self.name,self.items];
}

@end

