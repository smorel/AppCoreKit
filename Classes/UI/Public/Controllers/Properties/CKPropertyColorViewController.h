//
//  CKPropertyColorViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

/**
 */
@interface CKPropertyColorViewController : CKPropertyViewController

/** You can specify the order and a selected amount of component you want to display.
 For example if display a solid color with no alpha, you can specify [ @"red", "@green", @"blue" ] 
 Default value is nil meaning displaying all the components.
 */
@property(nonatomic,retain) NSSet* components;

@end
