//
//  CKPassThroughView.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPassThroughView.h"

@implementation CKPassThroughView

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    else return hitView;
}

@end
