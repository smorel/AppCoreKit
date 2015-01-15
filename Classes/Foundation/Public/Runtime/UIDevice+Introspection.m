//
//  UIDevice_Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-01-15.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "UIDevice+Introspection.h"
#import "CKPropertyExtendedAttributes.h"


@implementation UIDevice(Screen)

- (UIScreen*)mainScreen{
    return [UIScreen mainScreen];
}

- (void)userInterfaceIdiomExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UIUserInterfaceIdiom",
                                                 UIUserInterfaceIdiomUnspecified,
                                                 UIUserInterfaceIdiomPhone,
                                                 UIUserInterfaceIdiomPad);
}

@end