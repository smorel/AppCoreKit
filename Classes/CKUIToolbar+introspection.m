//
//  CKUIToolbar+introspection.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIToolbar+introspection.h"
#import "CKNSValueTransformer+Additions.h"


@implementation UIToolbar (CKIntrospectionAdditions)

- (void)barStyleMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"UIBarStyle", 
                                               UIBarStyleDefault,
                                               UIBarStyleBlack,
                                               UIBarStyleBlackOpaque,
                                               UIBarStyleBlackTranslucent);
}

@end
