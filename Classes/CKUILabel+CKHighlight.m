//
//  UILabel+CKHighlight.m
//  YellowPages
//
//  Created by Sebastien Morel on 11-12-12.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUILabel+CKHighlight.h"
#import "CKRuntime.h"


@implementation UILabel (CKHighlight)

- (void)ckSetHighlighted:(BOOL)highlighted{
    if(highlighted){
        UIColor* highlightedShadowColor = [self valueForKey:@"highlightedShadowColor"];
        if(highlightedShadowColor){
            [self setValue:[self valueForKey:@"shadowColor"] forKey:@"internalCopyOfShadowColor"];
            [self setValue:highlightedShadowColor forKey:@"shadowColor"];
        }
    }
    else{
        UIColor* copyOfShadowColor = [self valueForKey:@"internalCopyOfShadowColor"];
        if(copyOfShadowColor){
            [self setValue:copyOfShadowColor forKey:@"shadowColor"];
            [self setValue:nil forKey:@"internalCopyOfShadowColor"];
        }
    }
    [self ckSetHighlighted:highlighted];
}

+ (void)load{
    BOOL result = CKClassAddProperty([UILabel class],@"highlightedShadowColor", [UIColor class], CKClassPropertyDescriptorAssignementTypeRetain, YES);
    NSAssert(result, @"Unable to add highlightedShadowColor property");
    
    result = CKClassAddProperty([UILabel class],@"internalCopyOfShadowColor", [UIColor class], CKClassPropertyDescriptorAssignementTypeRetain, YES);
    NSAssert(result, @"Unable to add highlightedShadowColor property");
    
    CKSwizzleSelector([UILabel class],@selector(setHighlighted:),@selector(ckSetHighlighted:));
}

@end
