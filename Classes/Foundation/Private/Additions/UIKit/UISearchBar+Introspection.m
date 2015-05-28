//
//  UISearchBar+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-05-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UISearchBar+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation UISearchBar (Introspection)

- (void)barStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIBarStyle",
                                                 UIBarStyleDefault,
                                                 UIBarStyleBlack,
                                                 UIBarStyleBlackOpaque,
                                                 UIBarStyleBlackTranslucent);
}

- (void)searchBarStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UISearchBarStyle",
                                                 UISearchBarStyleDefault,
                                                 UISearchBarStyleProminent,
                                                 UISearchBarStyleMinimal);
}

@end
