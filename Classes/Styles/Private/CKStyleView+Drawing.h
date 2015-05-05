//
//  CKStyleView+Drawing.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-04-24.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStyleView.h"

@interface CKStyleView (Drawing)

- (UIImage*)maskImage;
- (UIImage*)borderImage;
- (UIImage*)gradientImage;
- (UIImage*)separatorImage;
- (UIImage*)embossTopImage;
- (UIImage*)embossBottomImage;

@end
