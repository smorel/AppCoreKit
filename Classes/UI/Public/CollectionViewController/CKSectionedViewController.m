//
//  CKSectionedViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSectionedViewController.h"
#import "UIView+Positioning.h"
#import <objc/runtime.h>


@interface CKResusableViewController ()
@property(nonatomic,assign) BOOL isComputingSize;
@end



@implementation UIView(CKSectionedViewController)
@dynamic attachedCellContentViewController;

static char UIViewAttachedCellContentViewControllerKey;

- (void)setAttachedCellContentViewController:(CKResusableViewController *)attachedCellContentViewController{
    objc_setAssociatedObject(self, &UIViewAttachedCellContentViewControllerKey, attachedCellContentViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKResusableViewController*)attachedCellContentViewController{
    return objc_getAssociatedObject(self, &UIViewAttachedCellContentViewControllerKey);
}

@end



@interface CKAbstractSection()
- (NSArray*)indexPathsForIndexes:(NSIndexSet*)indexes;
@end

@interface CKSectionedViewController ()
@property(nonatomic,retain,readwrite) NSArray* sections;
@end

@implementation CKSectionedViewController

- (void)dealloc{
    [self removeAllSectionsAnimated:NO];
    [_sections release];
    [super dealloc];
}


- (id)initWithSections:(NSArray*)sections{
    self = [super init];
    [self.mutableSections addObjectsFromArray:sections];
    return self;
}

- (void)postInit{
    [super postInit];
}

- (instancetype)controllerWithSections:(NSArray*)sections{
    return [[[[self class]alloc]initWithSections:sections]autorelease];
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
    [self willInsertSections:sections atIndexes:indexes animated:animated];
    
    [[self mutableSections]insertObjects:sections atIndexes:indexes];
    
    for(CKAbstractSection* section in sections){
        section.delegate = self;
    }
    
    [self didInsertSections:sections atIndexes:indexes animated:animated];
}

- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    NSArray* sections = [self sectionsAtIndexes:indexes];
    
    [self willRemoveSections:sections atIndexes:indexes animated:animated];
    
    //TODO : Update selectedIndexPaths
    
    for(CKAbstractSection* section in sections){
        section.delegate = nil;
    }
    [[self mutableSections]removeObjectsAtIndexes:indexes];
    
    [self didRemoveSections:sections atIndexes:indexes animated:animated];
}

- (NSArray*)indexPathsForIndexes:(NSIndexSet*)indexes inSection:(CKAbstractSection*)section{
    return [section indexPathsForIndexes:indexes];
}

- (void)section:(CKAbstractSection*)section willInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self willInsertControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
}

- (void)section:(CKAbstractSection*)section didInsertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self didInsertControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
}

- (void)section:(CKAbstractSection*)section willRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    //TODO : Update selectedIndexPaths
    [self willRemoveControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
}

- (void)section:(CKAbstractSection*)section didRemoveControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self didRemoveControllers:controllers atIndexPaths:[self indexPathsForIndexes:indexes inSection:section] animated:animated];
}


- (void)willInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated {}
- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated {}
- (void)willRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated {}
- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated {}
- (void)willInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated {}
- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated {}
- (void)willRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated {}
- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated {}


- (CKResusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath{
    CKAbstractSection* section = [self sectionAtIndex:indexPath.section];
    return [section controllerAtIndex:indexPath.row];
}

- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths{
    NSMutableArray* controllers = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for(NSIndexPath* indexPath in indexPaths){
        CKResusableViewController* controller = [self controllerAtIndexPath:indexPath];
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

- (UIView*)viewForController:(CKResusableViewController*)controller reusingView:(UIView*)view{
    
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
        CKResusableViewController* previousController = [view attachedCellContentViewController];
        if(previousController){
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
    
    [view setAttachedCellContentViewController:controller];
    
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
    CKResusableViewController* controller = [self controllerAtIndexPath:indexPath];
    return [self viewForController:controller reusingView:view];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    for(CKSection* section in self.sections){
        for(CKResusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewWillAppear:animated];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    for(CKSection* section in self.sections){
        for(CKResusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewWillDisappear:animated];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    for(CKSection* section in self.sections){
        for(CKResusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewDidAppear:animated];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    for(CKSection* section in self.sections){
        for(CKResusableViewController* controller in section.controllers){
            if([controller isViewLoaded]){
                [controller viewDidDisappear:animated];
            }
        }
    }
}

- (NSIndexPath*)indexPathForController:(CKResusableViewController*)controller{
    NSArray* indexPaths = [self indexPathsForControllers:@[controller]];
    return indexPaths.count > 0 ? [indexPaths firstObject] : nil;
}

- (NSArray*)indexPathsForControllers:(NSArray*)controllers{
    NSMutableArray* indexPaths = [NSMutableArray array];
    
    NSInteger sectionIndex = 0;
    for(CKSection* section in self.sections){
        
        NSInteger controllerIndex = 0;
        for(CKResusableViewController* controller in section.controllers){
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

- (CGSize)contentSizeForViewInPopover{
    return CGSizeMake(self.view.width,MIN(self.view.height,216));
}

@end
