//
//  CKResourceManager+UIUpdate.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-17.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKResourceManager.h"

@interface CKResourceManager (UIUpdate)

+ (void)reloadUI;


@end


@interface UIViewController (CKResourceManager)

- (void)resourceManagerReloadUI;

@end