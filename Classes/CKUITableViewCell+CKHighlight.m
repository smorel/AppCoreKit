//
//  UITableViewCell+CKHighlight.m
//  YellowPages
//
//  Created by Sebastien Morel on 11-12-12.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableViewCell+CKHighlight.h"
#import "CKRuntime.h"
#import "CKVersion.h"
#import <MapKit/MapKit.h>

@implementation UITableViewCell (CKHighlight)

+ (void)setView:(UIView*)view highlighted:(BOOL)highlighted animated:(BOOL)animated{
    //FIXME : find a better way to manage exceptions for this behavior
    if([view isKindOfClass:[UITableView class]] || [view isKindOfClass:[MKMapView class]]){
        return;
    }
    
    if([view respondsToSelector:@selector(setHighlighted:animated:)]){
        NSMethodSignature *signature = [view methodSignatureForSelector:@selector(setHighlighted:animated:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:@selector(setHighlighted:animated:)];
        [invocation setTarget:view];
        [invocation setArgument:&highlighted
                        atIndex:2];
        [invocation setArgument:&animated
                        atIndex:2];
        [invocation invoke];
    }
    else  if([view respondsToSelector:@selector(setHighlighted:)]){
        NSMethodSignature *signature = [view  methodSignatureForSelector:@selector(setHighlighted:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:@selector(setHighlighted:)];
        [invocation setTarget:view];
        [invocation setArgument:&highlighted
                        atIndex:2];
        [invocation invoke];
    }
    
    for(UIView* subView in view.subviews){
        [UITableViewCell setView:subView highlighted:highlighted animated:animated];
    }
}

- (void)ckSetHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [self ckSetHighlighted:highlighted animated:animated];
    if(self.selectionStyle != UITableViewCellSelectionStyleNone){
        for(UIView* subView in self.subviews){
            [UITableViewCell setView:subView highlighted:highlighted animated:animated];
        }
    }
}

+ (void)load{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    if([CKOSVersion() floatValue] >= 5.0){
        CKSwizzleSelector([UITableViewCell class],@selector(setHighlighted:animated:),@selector(ckSetHighlighted:animated:));
    }
    [pool release];
}

@end
