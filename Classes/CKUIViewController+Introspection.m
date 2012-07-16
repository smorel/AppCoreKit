//
//  CKUIViewController+Introspection.m
//  CloudKit
//
//  Created by Antoine Lamy.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIViewController+Introspection.h"
#import "CKNSValueTransformer+Additions.h"


@implementation UIViewController (CKIntrospectionAdditions)

+ (NSArray*)additionalClassPropertyDescriptors{
	NSMutableArray* properties = [NSMutableArray array];
	[properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"editing"
																		   readOnly:NO]];
	
	return properties;
}


@end
