//
//  CKUILabel+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-07.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUILabel+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"


@implementation UILabel (CKIntrospectionAdditions)

- (void)textAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UITextAlignment",
                                               UITextAlignmentLeft,
											   UITextAlignmentCenter,
											   UITextAlignmentRight);
}

- (void)lineBreakModeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UILineBreakMode",
                                               UILineBreakModeWordWrap,
											   UILineBreakModeCharacterWrap,
											   UILineBreakModeClip,
											   UILineBreakModeHeadTruncation,
											   UILineBreakModeTailTruncation,
											   UILineBreakModeMiddleTruncation);
}

- (void)baselineAdjustmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UIBaselineAdjustment",
                                               UIBaselineAdjustmentAlignBaselines,
											   UIBaselineAdjustmentAlignCenters,
											   UIBaselineAdjustmentNone);
}

@end
