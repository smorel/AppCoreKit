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
#import "CKModelObject.h"

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
