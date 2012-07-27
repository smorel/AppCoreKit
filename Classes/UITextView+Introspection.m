//
//  UITextView+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UITextView+Introspection.h"
#import "UITextInputTraits+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKObject.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation UITextView (CKIntrospectionAdditions)

UITEXTINPUTTRAITS_IMPLEMENTATION;

- (void)textAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextAlignment",
                                               UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)dataDetectorTypesExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UIDataDetectorTypes",
                                               UIDataDetectorTypePhoneNumber,
                                               UIDataDetectorTypeLink,
                                               UIDataDetectorTypeAddress,
                                               UIDataDetectorTypeCalendarEvent,
                                               UIDataDetectorTypeNone,
                                               UIDataDetectorTypeAll );
}

- (void)textExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.multiLineEnabled = YES;
}

@end
