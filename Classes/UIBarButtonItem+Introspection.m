//
//  UIBarButtonItem+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIBarButtonItem+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


@implementation UIBarButtonItem (CKIntrospectionAdditions)

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIBarButtonItemStyle", 
                                               UIBarButtonItemStylePlain,
                                               UIBarButtonItemStyleBordered,
                                               UIBarButtonItemStyleDone);
}

@end
