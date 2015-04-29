//
//  CKStyleView+Shadow.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-28.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

@interface CKStyleView (Shadow)

- (void)layoutShadowImageView;
- (void)regenerateShadow;
- (BOOL)shadowEnabled;

@end
