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


@implementation UIViewController (CKStyle)

- (NSMutableDictionary*)applyStyle{
	return [self applyStyleWithParentStyle:nil];
}

- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style{
    NSMutableDictionary* controllerStyle = style ? [style styleForObject:self  propertyName:nil] : [[CKStyleManager defaultManager] styleForObject:self  propertyName:nil];
	
    if([CKStyleManager logEnabled]){
        if([controllerStyle isEmpty]){
            NSLog(@"did not find style for controller %@",self);
        }
        else{
            NSLog(@"found style for controller %@",self);
        }
    }
    
	NSMutableSet* appliedStack = [NSMutableSet set];
	[self applySubViewsStyle:controllerStyle appliedStack:appliedStack delegate:nil];
    
    return controllerStyle;
}

@end
