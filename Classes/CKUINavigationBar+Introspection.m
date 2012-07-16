//
//  CKUINavigationBar+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUINavigationBar+Introspection.h"
#import "CKNSValueTransformer+Additions.h"

@implementation UINavigationBar (CKIntrospectionAdditions)

- (void)barStyleMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"UIBarStyle", 
                                               UIBarStyleDefault,
                                               UIBarStyleBlack,
                                               UIBarStyleBlackOpaque,
                                               UIBarStyleBlackTranslucent);
}

@end
