//
//  CKFormSectionBase.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormSectionBase.h"
#import "CKFormSectionBase_private.h"
#import "CKFormTableViewController.h"
#import "CKObjectController.h"
#import "CKItemViewControllerFactory.h"
#import "CKNSObject+Invocation.h"
#import "CKStyleManager.h"
#import "CKUIView+Style.h"
#import "CKTableViewCellController.h"
#import "CKTableViewCellController+Style.h"

#import "CKDebug.h"

//CKFormSectionBase

@implementation CKFormSectionBase
@synthesize headerTitle = _headerTitle;
@synthesize headerView = _headerView;
@synthesize footerTitle = _footerTitle;
@synthesize footerView = _footerView;
@synthesize parentController = _parentController;
@synthesize hidden = _hidden;
@synthesize collapsed =_collapsed;

- (id)init{
	[super init];
	_hidden = NO;
    _collapsed = NO;
	return self;
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


- (CKItemViewControllerFactoryItem*)factoryItemForIndex:(NSInteger)index{
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

- (void)setHeaderTitle:(NSString *)headerTitle{
    [_headerTitle release];
    _headerTitle = [headerTitle retain];
    [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setHeaderView:(UIView *)headerView{
    [_headerView release];
    _headerView = [headerView retain];
    
    if(_headerView){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:_parentController propertyName:nil];
        [_headerView applyStyle:controllerStyle];
    }
    
    [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setFooterTitle:(NSString *)footerTitle{
    [_footerTitle release];
    _footerTitle = [footerTitle retain];
    [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setFooterView:(UIView *)footerView{
    [_footerView release];
    _footerView = [footerView retain];
    if(_footerView){
        NSMutableDictionary* controllerStyle = [[CKStyleManager defaultManager] styleForObject:_parentController propertyName:nil];
        [_footerView applyStyle:controllerStyle];
    }
    
    [[_parentController tableView] reloadSections:[NSIndexSet indexSetWithIndex:[self sectionVisibleIndex]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setCollapsed:(BOOL)bo withRowAnimation:(UITableViewRowAnimation)animation{
    if(_collapsed != bo){
        self.collapsed = bo;
        if(_parentController.state == CKUIViewControllerStateDidAppear){
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
