//
//  UILabel+CKLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UILabel (CKLayout)

/** This attribute specify whether the label can be stretched horizontally to fill a bigger space. By default, the prefered size of a label fits to get the optimal size taking care of the label properties.
 You can either use Minimum/maximum/fixed size on a label with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 The default value is YES is the label is in a CKVerticalBoxLayout or NO in other conditions.
 */
@property(nonatomic,assign) BOOL flexibleWidth;


/** This attribute specify whether the label can be stretched vertically to fill a bigger space. By default, the prefered size of a label fits to get the optimal size taking care of the label properties.
 You can either use Minimum/maximum/fixed size on a label with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 The default value is NO.
 */
@property(nonatomic,assign) BOOL flexibleHeight;

/** This attribute specify whether the label can be stretched vertically and horizontally to fill a bigger space. By default, the prefered size of a label fits to get the optimal size taking care of the label properties.
 You can either use Minimum/maximum/fixed size on a label with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 The default value is NO.
 */
@property(nonatomic,assign) BOOL flexibleSize;

@end
