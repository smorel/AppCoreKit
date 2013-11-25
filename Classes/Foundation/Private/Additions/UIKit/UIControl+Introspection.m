//
//  UIControl+Introspection.m
//  AppCoreKit
//
//  Created by Nicolas Clapies on 11/25/2013.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UIControl+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation UIControl (Introspection)

- (void)contentVerticalAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UIControlContentVerticalAlignment",
                                                 UIControlContentVerticalAlignmentCenter,
                                                 UIControlContentVerticalAlignmentTop,
                                                 UIControlContentVerticalAlignmentBottom,
                                                 UIControlContentVerticalAlignmentFill);
}

- (void)contentHorizontalAlignmentExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"UIControlContentHorizontalAlignment",
                                                 UIControlContentHorizontalAlignmentCenter,
                                                 UIControlContentHorizontalAlignmentLeft,
                                                 UIControlContentHorizontalAlignmentRight,
                                                 UIControlContentHorizontalAlignmentFill);
}

@end
