//
//  CKAnimationPrivate.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 12-03-28.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "CKAnimation.h"

@interface CKAnimation()

@property(nonatomic,assign) NSTimeInterval cumulatedTime;
- (void)updateUsingRatio:(CGFloat)ratio;

@end