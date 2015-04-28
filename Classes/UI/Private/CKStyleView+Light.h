//
//  CKStyleView+Light.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView.h"

@interface CKStyleView (Shadow)

- (BOOL)shadowEnabled;
- (UIImage*)generateShadowImage;
- (BOOL)updateShadowOffsetWithLight;

- (CGRect)shadowImageViewFrame;

- (BOOL)highlightEnabled;
- (BOOL)updateHighlightOffsetWithLight;

@end
