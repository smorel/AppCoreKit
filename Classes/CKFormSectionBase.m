//
//  CKFormSectionBase.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKFormSectionBase_private.h"
#import "CKFormTableViewController.h"
#import "CKObjectController.h"
#import "CKCollectionCellControllerFactory.h"
#import "NSObject+Invocation.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "CKTableViewCellController.h"
#import "CKTableViewCellController+Style.h"
#import "CKSectionViews.h"
#import "NSObject+Bindings.h"

#import "CKDebug.h"

@interface CKSectionHeaderView()
@property(nonatomic,assign,readwrite) CKTableViewController* tableViewController;
@end

//CKFormSectionBase

@implementation CKFormSectionBase
{
	NSString* _headerTitle;
	UIView* _headerView;
	NSString* _footerTitle;
	UIView* _footerView;
	CKFormTableViewController* _parentController;
	BOOL _hidden;
}

@synthesize headerTitle = _headerTitle;
@synthesize headerView = _headerView;
@synthesize footerTitle = _footerTitle;
@synthesize footerView = _footerView;
@synthesize parentController = _parentController;
@synthesize hidden = _hidden;
@synthesize collapsed =_collapsed;

- (id)init{
    if (self = [super init]) {
      	_hidden = NO;
        _collapsed = NO;
    }
	return self;
}

- (void)dealloc{
    [self clearBindingsContext];
    [super dealloc];
}

- (NSInteger)sectionIndex{
	return [_parentController indexOfSection:self];
}

- (NSInteger)numberOfObjects{
	NSAssert(NO,@"Base Implementation");
	return 0;
}

- (id)objectAtIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
	return nil;
}


- (CKCollectionCellControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
    NSAssert(FALSE,@"Should not be called !");
    return nil;
}

- (id)controllerForObject:(id)object atIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
	return nil;
}

- (void)removeObjectAtIndex:(NSInteger)index{
	NSAssert(NO,@"Base Implementation");
}

- (void)lock{
}

- (void)unlock{
}

- (void)fetchRange:(NSRange)range{}

- (void)start{}
- (void)stop{}

- (NSInteger)sectionVisibleIndex{
	return [_parentController indexOfVisibleSection:self];
}

- (void)setParentController:(CKFormTableViewController *)theParentController{
    _parentController = theParentController;
    
    if([_headerView isKindOfClass:[CKSectionHeaderView class]]){
        CKSectionHeaderView* v = (CKSectionHeaderView*)_headerView;
        v.tableViewController = _parentController;
    }
    
    if([_footerView isKindOfClass:[CKSectionHeaderView class]]){
        CKSectionHeaderView* v = (CKSectionHeaderView*)_footerView;
        v.tableViewController = _parentController;
    }
}

- (void)setHeaderTitle:(NSString *)headerTitle{
    [_headerTitle release];
    _headerTitle = [headerTitle retain];
    
    if(!_headerView){
        CKSectionHeaderView* v = [[[CKSectionHeaderView alloc]init]autorelease];
        v.text = _headerTitle;
        [self setHeaderView:v];
    }else{
        if([_headerView isKindOfClass:[CKSectionHeaderView class]]){
            CKSectionHeaderView* v = (CKSectionHeaderView*)_headerView;
            v.text = _headerTitle;
        }
        [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setHeaderView:(UIView *)headerView{
    [_headerView release];
    _headerView = [headerView retain];
    
    if([headerView isKindOfClass:[CKSectionHeaderView class]]){
        CKSectionHeaderView* v = (CKSectionHeaderView*)headerView;
        v.tableViewController = _parentController;
    }
    
    [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setFooterTitle:(NSString *)footerTitle{
    [_footerTitle release];
    _footerTitle = [footerTitle retain];
    
    if(!_footerView){
        CKSectionHeaderView* v = [[[CKSectionHeaderView alloc]init]autorelease];
        v.text = _headerTitle;
        [self setFooterView:v];
    }else{
        if([_footerView isKindOfClass:[CKSectionHeaderView class]]){
            CKSectionHeaderView* v = (CKSectionHeaderView*)_headerView;
            v.text = _headerTitle;
        }
        [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)setFooterView:(UIView *)footerView{
    [_footerView release];
    _footerView = [footerView retain];
    
    if([footerView isKindOfClass:[CKSectionHeaderView class]]){
        CKSectionHeaderView* v = (CKSectionHeaderView*)footerView;
        v.tableViewController = _parentController;
    }
    
    [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setCollapsed:(BOOL)bo withRowAnimation:(UITableViewRowAnimation)animation{
    if(_collapsed != bo){
        self.collapsed = bo;
        if(_parentController.state == CKViewControllerStateDidAppear){
            NSInteger section = [_parentController indexOfSection:self];
            NSMutableArray* indexPaths = [NSMutableArray array];
            for(int i =0;i<[self numberOfObjects];++i){
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
                [indexPaths addObject:indexPath];
            }
            if(_collapsed){
                [_parentController.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
            }
            else{
                [_parentController.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
            }
        }
    }
}

@end
