//
//  CKTransitionTreeNavigationAnimator.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-21.
//  Copyright (c) 2015 Sebastien Morel. All rights reserved.
//

#import "CKTransitionTreeAnimator.h"

@interface CKTransitionTreeNavigationAnimator : CKTransitionTreeAnimator

@property(nonatomic,retain,readonly) CKTransitionTree* pushTransitionTree;
@property(nonatomic,retain,readonly) CKTransitionTree* popTransitionTree;
@property(nonatomic,assign) UINavigationControllerOperation operation;

@end
