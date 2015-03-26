//
//  CKAbstractSection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKAbstractSection.h"
#import "CKSectionContainer.h"
#import "CKContainerViewController.h"
#import "CKSectionHeaderFooterViewController.h"

@interface CKAbstractSection()
@property(nonatomic,retain, readwrite) NSArray* controllers;
- (NSMutableArray*)mutableControllers;
@end


@implementation CKAbstractSection

- (void)dealloc{
    [self clearBindingsContext];
    
    _delegate = nil;
    _containerViewController = nil;
    [_name release];
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

- (NSInteger)indexOfController:(CKReusableViewController*)controller{
    return [[self mutableControllers]indexOfObjectIdenticalTo:controller];
}

- (NSIndexSet*)indexesOfControllers:(NSArray*)controllers{
    return [[self mutableControllers] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [controllers containsObject:obj];
    }];
}

- (CKReusableViewController*)controllerAtIndex:(NSInteger)index{
    if(index >= [self mutableControllers].count)
        return nil;
    
    return [[self mutableControllers]objectAtIndex:index];
}

- (NSArray*)controllersAtIndexes:(NSIndexSet*)indexes{
    return [[self mutableControllers]objectsAtIndexes:indexes];
}

- (void)insertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(indexes.count <= 0)
        return;
    
    if(self.delegate){
        for(CKReusableViewController* controller in controllers){
            [controller setContainerViewController:self.containerViewController];
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

- (void)fetchNextPageFromIndex:(NSInteger)index{
    
}

- (void)setContainerViewController:(UIViewController *)containerViewController{
    _containerViewController = containerViewController;
    
    for(CKReusableViewController* controller in self.controllers){
        [controller setContainerViewController:_containerViewController];
    }
    
    [self.headerViewController setContainerViewController:_containerViewController];
    [self.footerViewController setContainerViewController:_containerViewController];
}

- (void)setHeaderViewController:(CKReusableViewController *)headerViewController{
    [_headerViewController release];
    _headerViewController = [headerViewController retain];
    if(_delegate){
        [headerViewController setContainerViewController:self.containerViewController];
    }
}

- (void)setFooterViewController:(CKReusableViewController *)footerViewController{
    [_footerViewController release];
    _footerViewController = [footerViewController retain];
    if(_delegate){
        [footerViewController setContainerViewController:self.containerViewController];
    }
}

- (void)setHeaderTitle:(NSString*)headerTitle{
    self.headerViewController = [CKSectionHeaderFooterViewController controllerWithType:CKSectionViewControllerTypeHeader text:headerTitle];
}

- (void)setFooterTitle:(NSString*)footerTitle{
    self.footerViewController = [CKSectionHeaderFooterViewController controllerWithType:CKSectionViewControllerTypeFooter text:footerTitle];
}

- (void)sectionContainerDelegate:(UIViewController<CKSectionContainerDelegate>*)sectionContainerDelegate willRemoveControllerAtIndex:(NSInteger)index{
    [self removeControllersAtIndexes:[NSIndexSet indexSetWithIndex:index] animated:YES];
}

- (void)sectionContainerDelegate:(UIViewController<CKSectionContainerDelegate>*)sectionContainerDelegate didMoveControllerAtIndex:(NSInteger)from toIndex:(NSInteger)to
{
    CKReusableViewController* controller = [[[self mutableControllers] objectAtIndex:from]retain];
    
    [[self mutableControllers] removeObjectAtIndex:from];
    [[self mutableControllers] insertObject:controller atIndex:to];
}

@end
