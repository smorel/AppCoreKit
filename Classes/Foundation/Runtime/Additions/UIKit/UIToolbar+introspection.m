//
//  UIToolbar+introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIToolbar+introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


@implementation UIToolbar (CKIntrospectionAdditions)

- (void)barStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIBarStyle", 
                                               UIBarStyleDefault,
                                               UIBarStyleBlack,
                                               UIBarStyleBlackOpaque,
                                               UIBarStyleBlackTranslucent);
}

@end
