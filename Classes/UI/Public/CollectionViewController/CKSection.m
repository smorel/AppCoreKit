//
//  CKSection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKSection.h"

@interface CKAbstractSection()
- (NSMutableArray*)mutableControllers;
- (void)insertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)removeControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
@end



@implementation CKSection

- (id)initWithControllers:(NSArray*)controllers{
    self = [super init];
    [self.mutableControllers addObjectsFromArray:controllers];
    return self;
}

+ (CKSection*)sectionWithControllers:(NSArray*)controllers{
    return [[[CKSection alloc]initWithControllers:controllers]autorelease];
}

- (void)addController:(CKReusableViewController*)controller animated:(BOOL)animated{
    [self insertController:controller atIndex:self.mutableControllers.count animated:animated];
}

- (void)insertController:(CKReusableViewController*)controller atIndex:(NSInteger)index animated:(BOOL)animated{
    [self insertControllers:@[controller] atIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)addControllers:(NSArray*)controllers animated:(BOOL)animated{
    [self insertControllers:controllers atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.mutableControllers.count, controllers.count)] animated:animated];
}

- (void)removeAllControllersAnimated:(BOOL)animated{
    [self removeControllersAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.mutableControllers.count)] animated:animated];
}

- (void)removeController:(CKReusableViewController*)controller animated:(BOOL)animated{
    NSInteger index = [self indexOfController:controller];
    [self removeControllerAtIndex:index animated:animated];
}

- (void)removeControllerAtIndex:(NSInteger)index animated:(BOOL)animated{    
    [self removeControllersAtIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)removeControllers:(NSArray*)controllers animated:(BOOL)animated{
    NSIndexSet* indexes = [self indexesOfControllers:controllers];
    [self removeControllersAtIndexes:indexes animated:animated];
}

- (void)insertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [super insertControllers:controllers atIndexes:indexes animated:animated];
}

- (void)removeControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [super removeControllersAtIndexes:indexes animated:animated];
}

@end
