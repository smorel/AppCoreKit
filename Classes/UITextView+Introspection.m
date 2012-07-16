//
//  UITextView+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UITextView+Introspection.h"
#import "UITextInputTraits+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKObject.h"

@implementation UITextView (CKIntrospectionAdditions)

UITEXTINPUTTRAITS_IMPLEMENTATION;

- (void)textAlignmentMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextAlignment",
                                               UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)dataDetectorTypesMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UIDataDetectorTypes",
                                               UIDataDetectorTypePhoneNumber,
                                               UIDataDetectorTypeLink,
                                               UIDataDetectorTypeAddress,
                                               UIDataDetectorTypeCalendarEvent,
                                               UIDataDetectorTypeNone,
                                               UIDataDetectorTypeAll );
}

@end
