//
//  CKUISegmentedControl+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUISegmentedControl+Introspection.h"
#import "CKNSValueTransformer+Additions.h"


@implementation UISegmentedControl (CKIntrospection)

- (void)segmentedControlStyleMetaData:(CKObjectPropertyMetaData*)metaData{
    metaData.enumDescriptor = CKEnumDefinition(@"UISegmentedControlStyle", 
                                               UISegmentedControlStylePlain,
                                               UISegmentedControlStyleBordered,
                                               UISegmentedControlStyleBar,
                                               UISegmentedControlStyleBezeled);
}

@end
