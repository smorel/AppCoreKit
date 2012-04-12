//
//  UITextView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-15.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UITextView+Introspection.h"
#import "UITextInputTraits+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObject.h"

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

@end
