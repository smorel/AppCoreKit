//
//  UITextInputTraits+Introspection.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

extern NSMutableSet *textInputTraitsProperties;
void introspectTraitsProperties();

#define UITEXTINPUTTRAITS_IMPLEMENTATION \
- (void)autocapitalizationTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{\
	attributes.enumDescriptor = CKEnumDefinition(@"UITextAutocapitalizationType",\
                                               UITextAutocapitalizationTypeNone,\
                                               UITextAutocapitalizationTypeWords,\
                                               UITextAutocapitalizationTypeSentences,\
                                               UITextAutocapitalizationTypeAllCharacters);\
}\
\
- (void)autocorrectionTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{\
	attributes.enumDescriptor = CKEnumDefinition(@"UITextAutocorrectionType",\
                                               UITextAutocorrectionTypeDefault,\
                                               UITextAutocorrectionTypeNo,\
                                               UITextAutocorrectionTypeYes);\
}\
\
- (void)keyboardTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{\
	attributes.enumDescriptor = CKEnumDefinition(@"UIKeyboardType",\
                                               UIKeyboardTypeDefault,\
                                               UIKeyboardTypeASCIICapable,\
                                               UIKeyboardTypeNumbersAndPunctuation,\
                                               UIKeyboardTypeURL,\
                                               UIKeyboardTypeNumberPad,\
                                               UIKeyboardTypePhonePad,\
                                               UIKeyboardTypeNamePhonePad,\
                                               UIKeyboardTypeEmailAddress,\
                                               UIKeyboardTypeDecimalPad,\
                                               UIKeyboardTypeAlphabet);\
}\
\
- (void)keyboardAppearanceExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{\
	attributes.enumDescriptor = CKEnumDefinition(@"UIKeyboardAppearance",\
                                               UIKeyboardAppearanceDefault,\
                                               UIKeyboardAppearanceAlert  );\
}\
\
- (void)returnKeyTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{\
	attributes.enumDescriptor = CKEnumDefinition(@"UIReturnKeyType",\
                                               UIReturnKeyDefault,\
                                               UIReturnKeyGo,\
                                               UIReturnKeyGoogle,\
                                               UIReturnKeyJoin,\
                                               UIReturnKeyNext,\
                                               UIReturnKeyRoute,\
                                               UIReturnKeySearch,\
                                               UIReturnKeySend,\
                                               UIReturnKeyYahoo,\
                                               UIReturnKeyDone,\
                                               UIReturnKeyEmergencyCall  );\
}\
\
- (id)valueForKey:(NSString *)key{\
	introspectTraitsProperties();\
	if ([textInputTraitsProperties containsObject:key])\
	{\
        UITextInputTraits* textInputTraits = nil;\
        object_getInstanceVariable(self, "_traits", (void **)(&textInputTraits));\
		return [textInputTraits valueForKey:key];\
	}\
    return [super valueForKey:key];\
}\
\
- (void)setValue:(id)value forKey:(NSString *)key{\
    introspectTraitsProperties();\
	if ([textInputTraitsProperties containsObject:key])\
	{\
        UITextInputTraits* textInputTraits = nil;\
        object_getInstanceVariable(self, "_traits", (void **)(&textInputTraits));\
		return [textInputTraits setValue:value forKey:key];\
	}\
    return [super setValue:value forKey:key];\
}\
\
- (void)setValue:(id)value forKeyPath:(NSString *)keyPath{\
    introspectTraitsProperties();\
	if ([textInputTraitsProperties containsObject:keyPath])\
	{\
        UITextInputTraits* textInputTraits = nil;\
        object_getInstanceVariable(self, "_traits", (void **)(&textInputTraits));\
		return [textInputTraits setValue:value forKeyPath:keyPath];\
	}\
    return [super setValue:value forKeyPath:keyPath];\
}\

