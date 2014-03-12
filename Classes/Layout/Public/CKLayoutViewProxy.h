//
//  CKLayoutViewProxy.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/18/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKLayoutBox.h"

@interface CKLayoutViewProxy : CKLayoutBox
@property(nonatomic,retain,readonly) UIView* view;
@property(nonatomic,retain) NSDictionary* viewAttributes;
@end
