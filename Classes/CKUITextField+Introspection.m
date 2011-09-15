//
//  CKUITextView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableViewCell+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKModelObject.h"

static NSMutableSet *textInputTraitsProperties = nil;

@implementation UITextField (CKIntrospectionAdditions)

- (void)autocapitalizationTypeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextAutocapitalizationType",
                                               UITextAutocapitalizationTypeNone,
                                               UITextAutocapitalizationTypeWords,
                                               UITextAutocapitalizationTypeSentences,
                                               UITextAutocapitalizationTypeAllCharacters);
}

- (void)autocorrectionTypeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextAutocorrectionType",
                                               UITextAutocorrectionTypeDefault,
                                               UITextAutocorrectionTypeNo,
                                               UITextAutocorrectionTypeYes);
}

- (void)keyboardTypeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UIKeyboardType",
                                               UIKeyboardTypeDefault,                
                                               UIKeyboardTypeASCIICapable,           
                                               UIKeyboardTypeNumbersAndPunctuation,  
                                               UIKeyboardTypeURL,                    
                                               UIKeyboardTypeNumberPad,              
                                               UIKeyboardTypePhonePad,               
                                               UIKeyboardTypeNamePhonePad,          
                                               UIKeyboardTypeEmailAddress,      
                                               UIKeyboardTypeDecimalPad,                                                            
                                               UIKeyboardTypeAlphabet);
}

- (void)keyboardAppearanceMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UIKeyboardAppearance",
                                               UIKeyboardAppearanceDefault,
                                               UIKeyboardAppearanceAlert  );
}

- (void)returnKeyTypeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UIReturnKeyType",
                                               UIReturnKeyDefault,
                                               UIReturnKeyGo,
                                               UIReturnKeyGoogle,
                                               UIReturnKeyJoin,
                                               UIReturnKeyNext,
                                               UIReturnKeyRoute,
                                               UIReturnKeySearch,
                                               UIReturnKeySend,
                                               UIReturnKeyYahoo,
                                               UIReturnKeyDone,
                                               UIReturnKeyEmergencyCall  );
}

- (void)textAlignmentMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextAlignment",
                                               UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)borderStyleMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextBorderStyle",
                                               UITextBorderStyleNone,
                                               UITextBorderStyleLine,
                                               UITextBorderStyleBezel,
                                               UITextBorderStyleRoundedRect
                                               );
}

- (void)clearButtonModeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextFieldViewMode",
                                               UITextFieldViewModeNever,
                                               UITextFieldViewModeWhileEditing,
                                               UITextFieldViewModeUnlessEditing,
                                               UITextFieldViewModeAlways
                                               );
}

- (void)leftViewModeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextFieldViewMode",
                                               UITextFieldViewModeNever,
                                               UITextFieldViewModeWhileEditing,
                                               UITextFieldViewModeUnlessEditing,
                                               UITextFieldViewModeAlways
                                               );
}

- (void)rightViewModeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextFieldViewMode",
                                               UITextFieldViewModeNever,
                                               UITextFieldViewModeWhileEditing,
                                               UITextFieldViewModeUnlessEditing,
                                               UITextFieldViewModeAlways
                                               );
}

- (void)introspectTraitsProperties{
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

//Overload to support KVO on traits properties!
- (id)valueForKey:(NSString *)key{
	[self introspectTraitsProperties];
	if ([textInputTraitsProperties containsObject:key])
	{
        UITextInputTraits* textInputTraits = nil;
        object_getInstanceVariable(self, "_traits", (void **)(&textInputTraits));
		return [textInputTraits valueForKey:key];
	}
		
    return [super valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key{
	[self introspectTraitsProperties];
	if ([textInputTraitsProperties containsObject:key])
	{
        UITextInputTraits* textInputTraits = nil;
        object_getInstanceVariable(self, "_traits", (void **)(&textInputTraits));
		return [textInputTraits setValue:value forKey:key];
	}
    
    return [super setValue:value forKey:key];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath{
	[self introspectTraitsProperties];
	if ([textInputTraitsProperties containsObject:keyPath])
	{
        UITextInputTraits* textInputTraits = nil;
        object_getInstanceVariable(self, "_traits", (void **)(&textInputTraits));
		return [textInputTraits setValue:value forKeyPath:keyPath];
	}
    
    return [super setValue:value forKeyPath:keyPath];
}

@end