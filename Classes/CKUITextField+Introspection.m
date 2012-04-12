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


- (void)textAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextAlignment",
                                               UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)borderStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextBorderStyle",
                                               UITextBorderStyleNone,
                                               UITextBorderStyleLine,
                                               UITextBorderStyleBezel,
                                               UITextBorderStyleRoundedRect
                                               );
}

- (void)clearButtonModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextFieldViewMode",
                                               UITextFieldViewModeNever,
                                               UITextFieldViewModeWhileEditing,
                                               UITextFieldViewModeUnlessEditing,
                                               UITextFieldViewModeAlways
                                               );
}

- (void)leftViewModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextFieldViewMode",
                                               UITextFieldViewModeNever,
                                               UITextFieldViewModeWhileEditing,
                                               UITextFieldViewModeUnlessEditing,
                                               UITextFieldViewModeAlways
                                               );
}

- (void)rightViewModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextFieldViewMode",
                                               UITextFieldViewModeNever,
                                               UITextFieldViewModeWhileEditing,
                                               UITextFieldViewModeUnlessEditing,
                                               UITextFieldViewModeAlways
                                               );
}

UITEXTINPUTTRAITS_IMPLEMENTATION;

@end