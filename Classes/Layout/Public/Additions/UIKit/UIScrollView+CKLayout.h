//
//  UIScrollView+CKLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/13/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import "UIView+CKLayout.h"

@interface UIScrollView (CKLayout)

/** This attribute specify whether the scrollView layoutboxes bounding box is limited to the scrollView width or if it is flexible
 Default value is YES
 */
@property(nonatomic,assign) BOOL flexibleContentWidth;

/** This attribute specify whether the scrollView layoutboxes bounding box is limited to the scrollView height or if it is flexible
 Default value is YES
 */
@property(nonatomic,assign) BOOL flexibleContentHeight;

/** This attribute specify whether the scrollView should automatically compute its content size using layoutboxes or not
 Default value is NO
 */
@property(nonatomic,assign) BOOL manuallyManagesContentSize;

@end
