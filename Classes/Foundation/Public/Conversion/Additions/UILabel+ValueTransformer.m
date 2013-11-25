//
//  UILabel+ValueTransformer.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-25.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UILabel+ValueTransformer.h"
#import "CKLocalization.h"

@implementation UILabel (ValueTransformer)

- (void)postProcessAfterConversion{
    if(self.text){
        NSString* localizedString = _(self.text);
        self.text = localizedString;
    }
}

@end
