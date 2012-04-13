//
//  CKUISegmentedControl+Introspection.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUISegmentedControl+Introspection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"


@implementation UISegmentedControl (CKIntrospection)

- (void)segmentedControlStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UISegmentedControlStyle", 
                                               UISegmentedControlStylePlain,
                                               UISegmentedControlStyleBordered,
                                               UISegmentedControlStyleBar,
                                               UISegmentedControlStyleBezeled);
}

@end
