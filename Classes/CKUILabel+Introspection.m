//
//  CKUILabel+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-07.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUILabel+Introspection.h"
#import "CKNSValueTransformer+Additions.h"


@implementation UILabel (CKIntrospectionAdditions)

- (void)textAlignmentMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UITextAlignment",
                                               UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)lineBreakModeMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UILineBreakMode",
                                               UILineBreakModeWordWrap,
											   UILineBreakModeCharacterWrap,
											   UILineBreakModeClip,
											   UILineBreakModeHeadTruncation,
											   UILineBreakModeTailTruncation,
											   UILineBreakModeMiddleTruncation);
}

- (void)baselineAdjustmentMetaData:(CKObjectPropertyMetaData*)metaData{
	metaData.enumDescriptor = CKEnumDefinition(@"UIBaselineAdjustment",
                                               UIBaselineAdjustmentAlignBaselines,
											   UIBaselineAdjustmentAlignCenters,
											   UIBaselineAdjustmentNone);
}

@end
