//
//  UITextInputTraits+Introspection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-15.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

extern NSMutableSet *textInputTraitsProperties;
void introspectTraitsProperties();

#define UITEXTINPUTTRAITS_IMPLEMENTATION \
- (void)autocapitalizationTypeMetaData:(CKObjectPropertyMetaData*)metaData{\
	metaData.enumDescriptor = CKEnumDefinition(@"UITextAutocapitalizationType",\
                                               UITextAutocapitalizationTypeNone,\
                                               UITextAutocapitalizationTypeWords,\
                                               UITextAutocapitalizationTypeSentences,\
                                               UITextAutocapitalizationTypeAllCharacters);\
}\
\
- (void)autocorrectionTypeMetaData:(CKObjectPropertyMetaData*)metaData{\
	metaData.enumDescriptor = CKEnumDefinition(@"UITextAutocorrectionType",\
                                               UITextAutocorrectionTypeDefault,\
                                               UITextAutocorrectionTypeNo,\
                                               UITextAutocorrectionTypeYes);\
}\
\
- (void)keyboardTypeMetaData:(CKObjectPropertyMetaData*)metaData{\
	metaData.enumDescriptor = CKEnumDefinition(@"UIKeyboardType",\
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
- (void)keyboardAppearanceMetaData:(CKObjectPropertyMetaData*)metaData{\
	metaData.enumDescriptor = CKEnumDefinition(@"UIKeyboardAppearance",\
                                               UIKeyboardAppearanceDefault,\
                                               UIKeyboardAppearanceAlert  );\
}\
\
- (void)returnKeyTypeMetaData:(CKObjectPropertyMetaData*)metaData{\
	metaData.enumDescriptor = CKEnumDefinition(@"UIReturnKeyType",\
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

