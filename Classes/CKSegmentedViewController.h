//
//  CKSegmentedViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-12-08.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKContainerViewController.h"
#import "CKSegmentedControl.h"

typedef enum CKSegmentedViewControllerPosition{
    CKSegmentedViewControllerPositionTop,
    CKSegmentedViewControllerPositionBottom,
    CKSegmentedViewControllerPositionNavigationBar,
    CKSegmentedViewControllerPositionToolBar
}CKSegmentedViewControllerPosition;

@interface CKSegmentedViewController : CKContainerViewController
@property(nonatomic,assign) CKSegmentedViewControllerPosition segmentPosition;
@property(nonatomic,retain,readonly) CKSegmentedControl* segmentedControl;
@end
