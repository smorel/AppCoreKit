//
//  CKPropertyNumberViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-13.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyNumberViewController.h"

@implementation CKPropertyNumberViewController

@end



@implementation CKPropertyExtendedAttributes (CKPropertyNumberViewController)

- (void)setPlaceholderValue:(NSNumber*)placeholderValue{
    [self.attributes setObject:placeholderValue forKey:@"CKPropertyExtendedAttributes_CKPropertyNumberViewController_placeholderValue"];
}

- (NSNumber*)placeholderValue{
    id value = [self.attributes objectForKey:@"CKPropertyExtendedAttributes_CKPropertyNumberViewController_placeholderValue"];
    return value;
}

@end