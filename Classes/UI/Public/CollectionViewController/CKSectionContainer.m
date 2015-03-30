//
//  CKSectionContainer.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionContainer.h"
#import "UIView+Positioning.h"
#import <objc/runtime.h>


@interface CKReusableViewController ()
@property(nonatomic,assign) BOOL isComputingSize;
@end



@implementation UIView(CKSectionedViewController)
@dynamic reusableViewController;

static char UIViewReusableViewControllerKey;

- (void)setReusableViewController:(CKReusableViewController *)reusableViewController{
    objc_setAssociatedObject(self, &UIViewReusableViewControllerKey, reusableViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKReusableViewController*)reusableViewController{
    return objc_getAssociatedObject(self, &UIViewReusableViewControllerKey);
}

@end



@interface CKAbstractSection()
- (NSArray*)indexPathsForIndexes:(NSIndexSet*)indexes;
@end

@interface CKSectionContainer ()
@property(nonatomic,retain,readwrite) NSArray* sections;
@property(nonatomic,assign,readwrite) UIViewController<CKSectionContainerDelegate>* delegate;
@end

@implementation CKSectionContainer

- (void)dealloc{
    [self removeAllSectionsAnimated:NO];
    [_sections release];
    _delegate = nil;
    [super dealloc];
}


- (id)initWithDelegate:(UIViewController<CKSectionContainerDelegate>*)delegate{
    self = [super init];
    self.delegate = delegate;
    return self;
}

- (id)initWithSections:(NSArray*)sections delegate:(UIViewController<CKSectionContainerDelegate>*)delegate{
    self = [super init];
    [self.mutableSections addObjectsFromArray:sections];
    return self;
}

- (NSMutableArray*)mutableSections{
    if(!self.sections){
        self.sections = [NSMutableArray array];
    }
    return (NSMutableArray*)self.sections;
}

- (CKAbstractSection*)sectionAtIndex:(NSInteger)index{
    return [[self mutableSections]objectAtIndex:index];
}

- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes{
    return [[self mutableSections]objectsAtIndexes:indexes];
}

- (NSInteger)indexOfSection:(CKAbstractSection*)section{
    return [[self mutableSections] indexOfObjectIdenticalTo:section];
}

- (NSIndexSet*)indexesOfSections:(NSArray*)sections{
    return [[self mutableSections] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [sections containsObject:obj];
    }];
}

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self insertSection:section atIndex:self.sections.count animated:animated];
}

- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated{
    [self insertSections:@[section] atIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)addSections:(NSArray*)sections animated:(BOOL)animated{
    [self insertSections:sections atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.sections.count,sections.count)] animated:animated];
}


- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated{
    NSInteger index = [self indexOfSection:section];
    [self removeSectionAtIndex:index animated:animated];
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated{
    [self removeSectionsAtIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)removeSections:(NSArray*)sections animated:(BOOL)animated{
    NSIndexSet* indexes = [self indexesOfSections:sections];
    [self removeSectionsAtIndexes:indexes animated:animated];
}

- (void)removeAllSectionsAnimated:(BOOL)animated{
    [self removeSectionsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.sections.count)] animated:animated];
}

- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if([self.delegate respondsToSelector:@selector(willInsertSections:atIndexes:animated:)]){
        [self.delegate willInsertSections:sections atIndexes:indexes animated:animated];
    }
    
    [[self mutableSections]insertObjects:sections atIndexes:indexes];
    
    for(CKAbstractSection* section in sections){
        section.delegate = self;
        section.containerViewController = self.delegate;
    }
    
    [self.delegate didInsertSections:sections atIndexes:indexes animated:animated];
}

- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    NSArray* sections = [self sectionsAtIndexes:indexes];
    
    if([self.delegate respondsToSelector:@selector(willRemoveSections:atIndexes:animated:)]){
        [self.delegate willRemoveSections:sections atIndexes:indexes animated:animated];
    }
    
    //TODO : Update selectedIndexPaths
    
    for(CKAbstractSection* section in sections){
        section.delegate = nil;
    }
    [[self mutableSections]removeObjectsAtIndexes:indexes];
    
    [self.delegate didRemoveSections:sections atIndexes:indexes animated:animated];
}

- (NSArray*)indexPathsForIndexes:(NSIndexSet*)indexes inSection:(CKAbstractSection*)section{
    return [section indexPathsForIndexes:indexes];
}

- (void)section:(CKAbstractSection*)section willInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if([self.delegate respondsToSelector:@selector(willInsertControllers:atIndexPaths:animated:)]){
        [self.delegate willInsertControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
    }
}

- (void)section:(CKAbstractSection*)section didInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.delegate didInsertControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
}

- (void)section:(CKAbstractSection*)section willRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    //TODO : Update selectedIndexPaths
    
    if([self.delegate respondsToSelector:@selector(willRemoveControllers:atIndexPaths:animated:)]){
        [self.delegate willRemoveControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
    }
}

- (void)section:(CKAbstractSection*)section didRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.delegate didRemoveControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
}


- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath{
    if(!indexPath)
        return nil;
    CKAbstractSection* section = [self sectionAtIndex:indexPath.section];
    return [section controllerAtIndex:indexPath.row];
}

- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths{
    if(!indexPaths)
        return nil;
    
    NSMutableArray* controllers = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for(NSIndexPath* indexPath in indexPaths){
        CKReusableViewController* controller = [self controllerAtIndexPath:indexPath];
        if(controller){
            [controllers addObject:controller];
        }
    }
    return controllers;
}


- (void)reload{
    
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion{
    if(updates){
        updates();
    }
    
    if(completion){
        completion(YES);
    }
}

- (UIView*)viewForController:(CKReusableViewController*)controller reusingView:(UIView*)view{
    
    UIView* contentView = nil;
    if(![NSObject isClass:[view class] exactKindOfClass:[UIView class]]){
        @try{
            contentView = [view valueForKey:@"contentView"];
        }
        @catch (NSException* e) {
        }
    }
    
    if(!view){
        contentView = view = [[UIView alloc]init];
        [controller prepareForReuseUsingContentView:view contentViewCell:view];
        [controller viewDidLoad];
        
    }else{
        CKReusableViewController* previousController = [view reusableViewController];
        if(previousController && previousController.contentViewCell == view){
            if(previousController.state != CKViewControllerStateDidDisappear){
                if(previousController.state != CKViewControllerStateWillDisappear){
                    [previousController viewWillDisappear:NO];
                }
                if(previousController.state != CKViewControllerStateDidDisappear){
                    [previousController viewDidDisappear:NO];
                }
            }
            
            [view clearBindingsContext];
            [previousController prepareForReuseUsingContentView:nil contentViewCell:nil];
        }
        
        [controller prepareForReuseUsingContentView:(contentView ? contentView : view) contentViewCell:view];
        
        if(!previousController){
            [controller viewDidLoad];
        }
    }
    
    [view setReusableViewController:controller];
    
    if(controller.state == CKViewControllerStateDidAppear)
        return view;
    
    if(controller.state != CKViewControllerStateWillAppear){
        [controller viewWillAppear:NO];
    }
    if(controller.state != CKViewControllerStateDidAppear){
        [controller viewDidAppear:NO];
    }
    
    return view;

}

- (UIView*)viewForControllerAtIndexPath:(NSIndexPath*)indexPath reusingView:(UIView*)view{
    CKReusableViewController* controller = [self controllerAtIndexPath:indexPath];
    return [self viewForController:controller reusingView:view];
}

- (void)handleViewWillAppearAnimated:(BOOL)animated{
    for(CKSection* section in self.sections){
        for(CKReusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewWillAppear:animated];
            }
        }
    }
}

- (void)handleViewWillDisappearAnimated:(BOOL)animated{
    for(CKSection* section in self.sections){
        for(CKReusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewWillDisappear:animated];
            }
        }
    }
}

- (void)handleViewDidAppearAnimated:(BOOL)animated{
    for(CKSection* section in self.sections){
        for(CKReusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewDidAppear:animated];
            }
        }
    }
}

- (void)handleViewDidDisappearAnimated:(BOOL)animated{
    for(CKSection* section in self.sections){
        for(CKReusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewDidDisappear:animated];
            }
        }
    }
}

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller{
    NSArray* indexPaths = [self indexPathsForControllers:@[controller]];
    return indexPaths.count > 0 ? [indexPaths firstObject] : nil;
}

- (NSArray*)indexPathsForControllers:(NSArray*)controllers{
    NSMutableArray* indexPaths = [NSMutableArray array];
    
    NSInteger sectionIndex = 0;
    for(CKSection* section in self.sections){
        
        NSInteger controllerIndex = 0;
        for(CKReusableViewController* controller in section.controllers){
            if([controllers indexOfObjectIdenticalTo:controller] != NSNotFound){
                [indexPaths addObject:[NSIndexPath indexPathForRow:controllerIndex inSection:sectionIndex]];
            }
            ++controllerIndex;
        }
        
        ++sectionIndex;
    }
    
    return indexPaths;
}

- (void)invalidateControllerAtIndexPath:(NSIndexPath*)indexPath{
    
}

@end
