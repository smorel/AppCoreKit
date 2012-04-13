//
//  CKUIToolbar+introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-07.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIToolbar+introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"


@implementation UIToolbar (CKIntrospectionAdditions)

- (void)barStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIBarStyle", 
                                               UIBarStyleDefault,
                                               UIBarStyleBlack,
                                               UIBarStyleBlackOpaque,
                                               UIBarStyleBlackTranslucent);
}

@end
