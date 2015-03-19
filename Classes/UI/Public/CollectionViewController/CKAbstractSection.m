//
//  CKAbstractSection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKAbstractSection.h"
#import "CKSectionedViewController.h"
#import "CKContainerViewController.h"
#import "CKStandardContentViewController.h"

@interface CKAbstractSection()
@property(nonatomic,retain, readwrite) NSArray* controllers;
- (NSMutableArray*)mutableControllers;
@end


@implementation CKAbstractSection

- (void)dealloc{
    [self clearBindingsContext];
    
    _delegate = nil;
    [_controllers release];
    [_headerViewController release];
    [_footerViewController release];
    [super dealloc];
}

- (NSMutableArray*)mutableControllers{
    if(self.controllers == nil){
        self.controllers = [NSMutableArray array];
    }
    return (NSMutableArray*)self.controllers;
}

- (id)init{
    self = [super init];
    self.hidden = NO;
    self.collapsed = NO;
    return self;
}

- (void)setHidden:(BOOL)hidden{
    [self setHidden:hidden animated:NO];
}

- (void)setCollapsed:(BOOL)collapsed{
    [self setCollapsed:collapsed animated:NO];
}

- (NSInteger)indexOfController:(CKCollectionCellContentViewController*)controller{
    return [[self mutableControllers]indexOfObjectIdenticalTo:controller];
}

- (NSIndexSet*)indexesOfControllers:(NSArray*)controllers{
    return [[self mutableControllers] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [controllers containsObject:obj];
    }];
}

- (CKCollectionCellContentViewController*)controllerAtIndex:(NSInteger)index{
    return [[self mutableControllers]objectAtIndex:index];
}

- (NSArray*)controllersAtIndexes:(NSIndexSet*)indexes{
    return [[self mutableControllers]objectsAtIndexes:indexes];
}

- (void)insertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(indexes.count <= 0)
        return;
    
    if(self.delegate){
        for(CKCollectionCellContentViewController* controller in controllers){
            [controller setContainerViewController:self.delegate];
        }
    }
    
    [self.delegate section:self willInsertControllers:controllers atIndexes:indexes animated:animated];
    [[self mutableControllers]insertObjects:controllers atIndexes:indexes];
    [self.delegate section:self didInsertControllers:controllers atIndexes:indexes animated:animated];
}

- (void)removeControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(indexes.count <= 0)
        return;
    
    NSArray* controllers = [[self mutableControllers]objectsAtIndexes:indexes];
    
    [self.delegate section:self willRemoveControllers:controllers atIndexes:indexes animated:animated];
    [[self mutableControllers]removeObjectsAtIndexes:indexes];
    [self.delegate section:self didRemoveControllers:controllers atIndexes:indexes animated:animated];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated{
    if(_hidden == hidden)
        return;
    
    _hidden = hidden;
    //TODO
}

- (void)setCollapsed:(BOOL)collapsed animated:(BOOL)animated{
    if(_collapsed == collapsed)
        return;
    
    _collapsed = collapsed;
    //TODO
}

- (NSInteger)sectionIndex{
    return self.delegate ? [self.delegate indexOfSection:self] : NSNotFound;
}

- (NSArray*)indexPathsForIndexes:(NSIndexSet*)indexes{
    NSInteger index = self.sectionIndex;
    
    NSMutableArray* indexPaths = [NSMutableArray array];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:idx inSection:index];
        [indexPaths addObject:indexPath];
    }];
    
    return indexPaths;
}

- (void)fetchNextPage{
    
}

- (void)setDelegate:(CKSectionedViewController *)delegate{
    [_delegate release];
    _delegate = [delegate retain];
    
    for(CKCollectionCellContentViewController* controller in self.controllers){
        [controller setContainerViewController:_delegate];
    }
    
    [self.headerViewController setContainerViewController:_delegate];
    [self.footerViewController setContainerViewController:_delegate];
}

- (void)setHeaderViewController:(CKCollectionCellContentViewController *)headerViewController{
    [_headerViewController release];
    _headerViewController = [headerViewController retain];
    if(_delegate){
        [headerViewController setContainerViewController:_delegate];
    }
}

- (void)setFooterViewController:(CKCollectionCellContentViewController *)footerViewController{
    [_footerViewController release];
    _footerViewController = [footerViewController retain];
    if(_delegate){
        [footerViewController setContainerViewController:_delegate];
    }
}

- (void)setHeaderTitle:(NSString*)headerTitle{
    self.headerViewController = [CKStandardContentViewController controllerWithTitle:headerTitle action:nil];
}

- (void)setFooterTitle:(NSString*)footerTitle{
    self.footerViewController = [CKStandardContentViewController controllerWithTitle:footerTitle action:nil];
}

@end
