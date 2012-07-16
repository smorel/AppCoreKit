//
//  CKUIBarButtonItem+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIBarButtonItem+Introspection.h"
#import "CKNSValueTransformer+Additions.h"


@implementation UIBarButtonItem (CKIntrospectionAdditions)

- (void)styleMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"UIBarButtonItemStyle", 
                                               UIBarButtonItemStylePlain,
                                               UIBarButtonItemStyleBordered,
                                               UIBarButtonItemStyleDone);
}

@end
