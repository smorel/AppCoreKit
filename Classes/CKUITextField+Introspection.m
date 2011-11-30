//
//  CKUITextView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableViewCell+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObject.h"
#import "UITextInputTraits+Introspection.h"

@implementation UITextField (CKIntrospectionAdditions)


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

UITEXTINPUTTRAITS_IMPLEMENTATION;

@end