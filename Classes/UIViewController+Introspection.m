//
//  UIViewController+Introspection.m
//  AppCoreKit
//
//  Created by Antoine Lamy.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIViewController+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


@implementation UIViewController (CKIntrospectionAdditions)

+ (NSArray*)additionalClassPropertyDescriptors{
	NSMutableArray* properties = [NSMutableArray array];
	[properties addObject:[CKClassPropertyDescriptor boolDescriptorForPropertyNamed:@"editing"
																		   readOnly:NO]];
	
	return properties;
}


@end
