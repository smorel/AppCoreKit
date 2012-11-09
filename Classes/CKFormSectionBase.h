//
//  CKFormSectionBase.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKObject.h"


@class CKFormTableViewController;

/**
 */
@interface CKFormSectionBase : CKObject

///-----------------------------------
/// @name Customizing Section
///-----------------------------------

/**
 */
@property (nonatomic,retain) NSString* headerTitle;

/**
 */
@property (nonatomic,retain) UIView* headerView;

/**
 */
@property (nonatomic,retain) NSString* footerTitle;

/**
 */
@property (nonatomic,retain) UIView* footerView;

///-----------------------------------
/// @name Getting the parent form controller
///-----------------------------------

/**
 */
@property (nonatomic,assign,readonly) CKFormTableViewController* parentController;

///-----------------------------------
/// @name Getting the index in parent form controller
///-----------------------------------

/**
 */
@property (nonatomic,readonly) NSInteger sectionIndex;

/**
 */
@property (nonatomic,readonly) NSInteger sectionVisibleIndex;

///-----------------------------------
/// @name Hiding the Section
///-----------------------------------

/**
 */
@property (nonatomic,readonly) BOOL hidden;

///-----------------------------------
/// @name Collapsing the section
///-----------------------------------

/**
 */
@property (nonatomic, assign, readonly) BOOL collapsed;

/**
 */
- (void)setCollapsed:(BOOL)collapsed withRowAnimation:(UITableViewRowAnimation)animation;

///-----------------------------------
/// @name Querying the section
///-----------------------------------

/**
 */
- (NSInteger)numberOfObjects;

/**
 */
- (id)objectAtIndex:(NSInteger)index;

@end