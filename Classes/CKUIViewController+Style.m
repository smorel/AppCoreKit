//
//  CKUIViewController+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKDebug.h"


@implementation UIViewController (CKStyle)

- (NSMutableDictionary*)controllerStyle{
    NSMutableDictionary* previousControllerStyle = nil;
    NSInteger index = [self.navigationController.viewControllers indexOfObjectIdenticalTo:self];
    if(index != NSNotFound && index >= 1){
        UIViewController* previousViewController = [self.navigationController.viewControllers objectAtIndex:index - 1];
        previousControllerStyle = [[CKStyleManager defaultManager] styleForObject:previousViewController  propertyName:nil];
    }
    
    NSMutableArray* controllerStack = [NSMutableArray array];
    UIViewController* c = self;
    while(c){
        if([c respondsToSelector:@selector(containerViewController)]){
            c = [c performSelector:@selector(containerViewController)];
            if(c){
                [controllerStack insertObject:c atIndex:0];
            }
        }
        else{
            c = nil;
        }
    }
    
    for(UIViewController* controller in controllerStack){
        previousControllerStyle = previousControllerStyle ? [previousControllerStyle styleForObject:controller  propertyName:nil] : [[CKStyleManager defaultManager] styleForObject:controller  propertyName:nil];
    }
    
    return previousControllerStyle ? [previousControllerStyle styleForObject:self  propertyName:nil] : [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
}

- (NSMutableDictionary* )applyStyle{
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    
    NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];

    return controllerStyle;
}

- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style{
    NSMutableDictionary* controllerStyle = style ? [style styleForObject:self  propertyName:nil] : [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
	
    if([CKStyleManager logEnabled]){
        if([controllerStyle isEmpty]){
            CKDebugLog(@"did not find style for controller %@",self);
        }
        else{
            CKDebugLog(@"found style for controller %@",self);
        }
    }
    
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];
    
    return controllerStyle;
}

@end
