//
//  CKStyleView+Shadow.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView.h"

@interface CKStyleView (Shadow)

- (BOOL)shadowEnabled;
- (CGRect)shadowImageViewFrame;
- (UIImage*)generateShadowImage;

@end
