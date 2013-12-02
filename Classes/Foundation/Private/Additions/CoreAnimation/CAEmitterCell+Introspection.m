//
//  CAEmitterCell+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-08.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CAEmitterCell+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

@implementation CAEmitterCell (Introspection)

- (void)contentsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [UIImage class];
}

- (void)postProcessAfterConversion{
    if([self.contents isKindOfClass:[UIImage class]]){
        self.contents = (id)[(UIImage*)self.contents CGImage];
    }
}

@end
