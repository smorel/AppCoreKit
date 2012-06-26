//
//  CKFormSectionBase.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKObject.h"


@class CKFormTableViewController;

/**
 */
@interface CKFormSectionBase : CKObject
{
	NSString* _headerTitle;
	UIView* _headerView;
	NSString* _footerTitle;
	UIView* _footerView;
	CKFormTableViewController* _parentController;
	BOOL _hidden;
}

@property (nonatomic,retain) NSString* headerTitle;
@property (nonatomic,retain) UIView* headerView;
@property (nonatomic,retain) NSString* footerTitle;
@property (nonatomic,retain) UIView* footerView;
@property (nonatomic,readonly) NSInteger sectionIndex;
@property (nonatomic,readonly) NSInteger sectionVisibleIndex;
@property (nonatomic,readonly) BOOL hidden;
@property (nonatomic, assign, readonly) BOOL collapsed;
@property (nonatomic,assign,readonly) CKFormTableViewController* parentController;

- (void)setCollapsed:(BOOL)collapsed withRowAnimation:(UITableViewRowAnimation)animation;

- (NSInteger)numberOfObjects;
- (id)objectAtIndex:(NSInteger)index;

@end