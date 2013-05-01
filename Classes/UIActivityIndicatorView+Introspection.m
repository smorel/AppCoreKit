//
//  UIActivityIndicatorView+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 13-05-01.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UIActivityIndicatorView+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation UIActivityIndicatorView (Introspection)

- (void)activityIndicatorViewStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIActivityIndicatorViewStyle",
                                                 UIActivityIndicatorViewStyleWhiteLarge,
                                                 UIActivityIndicatorViewStyleWhite,
                                                 UIActivityIndicatorViewStyleGray);
}


@end
