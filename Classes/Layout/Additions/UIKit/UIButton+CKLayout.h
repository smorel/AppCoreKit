//
//  UIButton+CKLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBoxProtocol.h"
#import "CKLayoutBox.h"

/**
 */
@interface UIButton (CKLayout)

/** This attribute specify whether the button can be stretched horizontally to fill a bigger space. By default, the prefered size of a button uses sizeToFit in order to get the optimal size of a button.
 You can either use Minimum/maximum/fixed size on a button with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 */
@property(nonatomic,assign) BOOL flexibleWidth;


/** This attribute specify whether the button can be stretched vertically to fill a bigger space. By default, the prefered size of a button uses sizeToFit in order to get the optimal size of a button.
 You can either use Minimum/maximum/fixed size on a button with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 */
@property(nonatomic,assign) BOOL flexibleHeight;

/** This attribute specify whether the button can be stretched vertically and horizontally to fill a bigger space. By default, the prefered size of a button uses sizeToFit in order to get the optimal size of a button.
 You can either use Minimum/maximum/fixed size on a button with flexibleWidth = NO to manage its size manually, or set flexibleWidth = YES to make it fill the space as much as possible.
 */
@property(nonatomic,assign) BOOL flexibleSize;

@end