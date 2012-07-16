//
//  UITextInputTraits+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UITextInputTraits+Introspection.h"
#import "CKNSValueTransformer+Additions.h"

NSMutableSet *textInputTraitsProperties = nil;

void introspectTraitsProperties(){
    if (!textInputTraitsProperties)
	{
		textInputTraitsProperties = [[NSMutableSet alloc] init];
		unsigned int count = 0;
		objc_property_t *properties = protocol_copyPropertyList(@protocol(UITextInputTraits), &count);
		for (unsigned int i = 0; i < count; i++)
		{
			objc_property_t property = properties[i];
			NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
			[textInputTraitsProperties addObject:propertyName];
		}
		free(properties);
	}
}