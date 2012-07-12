//
//  UILabel+Highlight.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "UILabel+Highlight.h"
#import "CKRuntime.h"


@implementation UILabel (CKHighlight)
@dynamic highlightedShadowColor,highlightedBackgroundColor;

- (void)ckSetHighlighted:(BOOL)highlighted{
    if(highlighted){
        UIColor* highlightedShadowColor = [self valueForKey:@"highlightedShadowColor"];
        if(highlightedShadowColor){
            [self setValue:[self valueForKey:@"shadowColor"] forKey:@"internalCopyOfShadowColor"];
            [self setValue:highlightedShadowColor forKey:@"shadowColor"];
        }
        
        UIColor* highlightedBackgroundColor = [self valueForKey:@"highlightedBackgroundColor"];
        if(highlightedBackgroundColor){
            [self setValue:[self valueForKey:@"backgroundColor"] forKey:@"internalCopyOfBackgroundColor"];
            [self setValue:highlightedBackgroundColor forKey:@"backgroundColor"];
        }
    }
    else{
        UIColor* copyOfShadowColor = [self valueForKey:@"internalCopyOfShadowColor"];
        if(copyOfShadowColor){
            [self setValue:copyOfShadowColor forKey:@"shadowColor"];
            [self setValue:nil forKey:@"internalCopyOfShadowColor"];
        }
        
        UIColor* copyOfBackgroundColor = [self valueForKey:@"internalCopyOfBackgroundColor"];
        if(copyOfBackgroundColor){
            [self setValue:copyOfBackgroundColor forKey:@"backgroundColor"];
            [self setValue:nil forKey:@"internalCopyOfBackgroundColor"];
        }
    }
    [self ckSetHighlighted:highlighted];
}

+ (void)load{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    BOOL result = CKClassAddProperty([UILabel class],@"highlightedShadowColor", [UIColor class], CKClassPropertyDescriptorAssignementTypeRetain, YES);
    NSAssert(result, @"Unable to add highlightedShadowColor property");
    
    result = CKClassAddProperty([UILabel class],@"highlightedBackgroundColor", [UIColor class], CKClassPropertyDescriptorAssignementTypeRetain, YES);
    NSAssert(result, @"Unable to add highlightedBackgroundColor property");
    
    result = CKClassAddProperty([UILabel class],@"internalCopyOfShadowColor", [UIColor class], CKClassPropertyDescriptorAssignementTypeRetain, YES);
    NSAssert(result, @"Unable to add internalCopyOfShadowColor property");
    
    result = CKClassAddProperty([UILabel class],@"internalCopyOfBackgroundColor", [UIColor class], CKClassPropertyDescriptorAssignementTypeRetain, YES);
    NSAssert(result, @"Unable to add internalCopyOfBackgroundColor property");
    
    CKSwizzleSelector([UILabel class],@selector(setHighlighted:),@selector(ckSetHighlighted:));
    [pool release];
}

@end
