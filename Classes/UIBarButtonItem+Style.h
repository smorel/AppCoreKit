//
//  UIBarButtonItem+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CKBarButtonItemButton : UIButton
@property (nonatomic,assign)UIBarButtonItem* barButtonItem;
- (id)initWithBarButtonItem:(UIBarButtonItem*)barButtonItem;

@end

@interface UIBarButtonItem (CKStyle)

@end
