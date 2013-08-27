//
//  UITextView+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UITableViewCell+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKObject.h"
#import "UITextInputTraits+Introspection.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

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

- (void)textExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.multiLineEnabled = YES;
}

UITEXTINPUTTRAITS_IMPLEMENTATION;

@end