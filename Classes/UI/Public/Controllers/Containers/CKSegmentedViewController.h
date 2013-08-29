//
//  CKSegmentedViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKContainerViewController.h"
#import "CKSegmentedControl.h"


/**
 */
typedef enum CKSegmentedViewControllerPosition{
    CKSegmentedViewControllerPositionTop,
    CKSegmentedViewControllerPositionBottom,
    CKSegmentedViewControllerPositionNavigationBar,
    CKSegmentedViewControllerPositionToolBar
}CKSegmentedViewControllerPosition;


/**
 */
@interface CKSegmentedViewController : CKContainerViewController

///-----------------------------------
/// @name Getting the segmented control
///-----------------------------------

/**
 */
@property(nonatomic,retain,readonly) CKSegmentedControl* segmentedControl;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property(nonatomic,assign) CKSegmentedViewControllerPosition segmentPosition;

@end
