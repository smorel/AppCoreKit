//
//  CKBlurModalDebugViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/26/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKBlurModalViewController.h"

/** Presenting this view controller as CKBlurModalViewController's content view controller, allows to tweak the CKBlurModalViewController's blur and animation dynamically for designers.
 */
@interface CKBlurModalDebugViewController : CKViewController
@property(nonatomic,assign) CKBlurModalViewController* blurModalViewController;

- (id)initWithBlurModalViewController:(CKBlurModalViewController*)blurModalViewController;

@end
