//
//  UISegmentedControl+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UISegmentedControl+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"


@implementation UISegmentedControl (CKIntrospection)

- (void)segmentedControlStyleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UISegmentedControlStyle", 
                                               UISegmentedControlStylePlain,
                                               UISegmentedControlStyleBordered,
                                               UISegmentedControlStyleBar,
                                               UISegmentedControlStyleBezeled);
}

@end
