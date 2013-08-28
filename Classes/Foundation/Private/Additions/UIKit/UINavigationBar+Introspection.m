//
//  UINavigationBar+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UINavigationBar+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation UINavigationBar (CKIntrospectionAdditions)

- (void)barStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIBarStyle", 
                                               UIBarStyleDefault,
                                               UIBarStyleBlack,
                                               UIBarStyleBlackOpaque,
                                               UIBarStyleBlackTranslucent);
}

@end
