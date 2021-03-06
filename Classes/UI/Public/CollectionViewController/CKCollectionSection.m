//
//  CKCollectionSection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKCollectionSection.h"
#import "CKSectionContainer.h"
#import "CKWeakRef.h"

@interface CKAbstractSection()
- (NSMutableArray*)mutableControllers;
- (void)insertControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (void)removeControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;
- (NSArray*)indexPathsForIndexes:(NSIndexSet*)indexes;
@end

@interface CKCollectionSection()

@property(nonatomic,retain, readwrite) NSArray* collectionControllers;
@property(nonatomic,retain, readwrite) NSArray* collectionHeaderControllers;
@property(nonatomic,retain, readwrite) NSArray* collectionFooterControllers;
@property(nonatomic,retain, readwrite) CKCollection* collection;
@property(nonatomic,retain, readwrite) CKReusableViewControllerFactory* factory;
@property(nonatomic,retain, readwrite) NSString* collectionBindingContext;

@end


@implementation CKCollectionSection

- (void)dealloc{
    [NSObject removeAllBindingsForContext:self.collectionBindingContext];
    [_collectionBindingContext release];
    [_collectionControllers release];
    [_collectionHeaderControllers release];
    [_collectionFooterControllers release];
    [_collection release];
    [_factory release];
    [super dealloc];
}

- (id)initWithCollection:(CKCollection*)collection factory:(CKReusableViewControllerFactory*)factory{
    return [self initWithCollection:collection factory:factory reorderingEnabled:NO];
}

+ (CKCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKReusableViewControllerFactory*)factory{
    return [[[CKCollectionSection alloc]initWithCollection:collection factory:factory]autorelease];
}

+ (CKCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKReusableViewControllerFactory*)factory headerTitle:(NSString*)headerTitle{
    CKCollectionSection* section = [CKCollectionSection sectionWithCollection:collection factory:factory];
    [section setHeaderTitle:headerTitle];
    return section;
}

- (id)initWithCollection:(CKCollection*)collection factory:(CKReusableViewControllerFactory*)factory reorderingEnabled:(BOOL)reorderingEnabled{
    self = [super init];
    self.collection = collection;
    self.factory = factory;
    self.reorderingEnabled = reorderingEnabled;
    return self;
}

+ (CKCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKReusableViewControllerFactory*)factory reorderingEnabled:(BOOL)reorderingEnabled{
    return [[[CKCollectionSection alloc]initWithCollection:collection factory:factory reorderingEnabled:reorderingEnabled]autorelease];
}

+ (CKCollectionSection*)sectionWithCollection:(CKCollection*)collection factory:(CKReusableViewControllerFactory*)factory headerTitle:(NSString*)headerTitle reorderingEnabled:(BOOL)reorderingEnabled{
    CKCollectionSection* section = [CKCollectionSection sectionWithCollection:collection factory:factory reorderingEnabled:reorderingEnabled];
    [section setHeaderTitle:headerTitle];
    return section;
}

- (void)setContainerViewController:(UIViewController *)containerViewController{
    [super setContainerViewController:containerViewController];
    
    if(containerViewController){
        [self setupCollectionControllersByUpdatingCollectionController:YES];
    }
}

- (NSMutableArray*)mutableCollectionControllers{
    if(self.collectionControllers == nil){
        self.collectionControllers = [NSMutableArray array];
    }
    return (NSMutableArray*)self.collectionControllers;
}

- (NSMutableArray*)mutableCollectionHeaderControllers{
    if(self.collectionHeaderControllers == nil){
        self.collectionHeaderControllers = [NSMutableArray array];
    }
    return (NSMutableArray*)self.collectionHeaderControllers;
}

- (NSMutableArray*)mutableCollectionFooterControllers{
    if(self.collectionFooterControllers == nil){
        self.collectionFooterControllers = [NSMutableArray array];
    }
    return (NSMutableArray*)self.collectionFooterControllers;
}

- (NSIndexSet*)indexesForCollectionHeaderIndexes:(NSIndexSet*)indexes{
    return indexes;
}

- (NSIndexSet*)indexesForCollectionIndexes:(NSIndexSet*)indexes{
    NSMutableIndexSet* modified = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [modified addIndex:idx + self.collectionHeaderControllers.count];
    }];
    return modified;
}

- (NSIndexSet*)indexesForCollectionFooterIndexes:(NSIndexSet*)indexes{
    NSMutableIndexSet* modified = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [modified addIndex:idx + self.collectionHeaderControllers.count + self.collectionControllers.count];
    }];
    return modified;
}





- (void)addCollectionHeaderController:(CKReusableViewController*)controller animated:(BOOL)animated{
    [self insertCollectionHeaderController:controller atIndex:self.collectionHeaderControllers.count animated:animated];
}

- (void)insertCollectionHeaderController:(CKReusableViewController*)controller atIndex:(NSInteger)index animated:(BOOL)animated{
    [self insertCollectionHeaderControllers:@[controller] atIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)addCollectionHeaderControllers:(NSArray*)controllers animated:(BOOL)animated{
    [self insertCollectionHeaderControllers:controllers atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.collectionHeaderControllers.count, controllers.count)] animated:animated];
}

- (void)removeAllCollectionHeaderControllersAnimated:(BOOL)animated{
    [self removeCollectionHeaderControllersAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionHeaderControllers.count)] animated:animated];
}

- (void)removeCollectionHeaderController:(CKReusableViewController*)controller animated:(BOOL)animated{
    NSInteger index = [[self mutableCollectionHeaderControllers]indexOfObjectIdenticalTo:controller];
    [self removeCollectionHeaderControllerAtIndex:index animated:animated];
}

- (void)removeCollectionHeaderControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    if(index == NSNotFound)
        return;
    [self removeCollectionHeaderControllersAtIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)removeCollectionHeaderControllers:(NSArray*)controllers animated:(BOOL)animated{
    NSIndexSet* indexes = [[self mutableCollectionHeaderControllers]indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [controllers containsObject:obj];
    }];
    [self removeCollectionHeaderControllersAtIndexes:indexes animated:animated];
}

- (void)insertCollectionHeaderControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [[self mutableCollectionHeaderControllers]insertObjects:controllers atIndexes:indexes];
    [super insertControllers:controllers atIndexes:[self indexesForCollectionHeaderIndexes:indexes] animated:animated];
}

- (void)removeCollectionHeaderControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    NSMutableIndexSet* mi = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if(idx != NSNotFound){
            [mi addIndex:idx];
        }
    }];
    
    [[self mutableCollectionHeaderControllers]removeObjectsAtIndexes:mi];
    [super removeControllersAtIndexes:[self indexesForCollectionHeaderIndexes:mi] animated:animated];
}






- (void)addCollectionFooterController:(CKReusableViewController*)controller animated:(BOOL)animated{
    [self insertCollectionFooterController:controller atIndex:self.mutableCollectionFooterControllers.count animated:animated];
}

- (void)insertCollectionFooterController:(CKReusableViewController*)controller atIndex:(NSInteger)index animated:(BOOL)animated{
    if(index == NSNotFound)
        return;
    [self insertCollectionFooterControllers:@[controller] atIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)addCollectionFooterControllers:(NSArray*)controllers animated:(BOOL)animated{
    [self insertCollectionFooterControllers:controllers atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.mutableCollectionFooterControllers.count, controllers.count)] animated:animated];
}

- (void)removeAllCollectionFooterControllersAnimated:(BOOL)animated{
    [self removeCollectionFooterControllersAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.mutableCollectionFooterControllers.count)] animated:animated];
}

- (void)removeCollectionFooterController:(CKReusableViewController*)controller animated:(BOOL)animated{
    NSInteger index = [[self mutableCollectionFooterControllers]indexOfObjectIdenticalTo:controller];
    [self removeCollectionFooterControllerAtIndex:index animated:animated];
}

- (void)removeCollectionFooterControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
    if(index == NSNotFound)
        return;
    [self removeCollectionFooterControllersAtIndexes:[NSIndexSet indexSetWithIndex:index] animated:animated];
}

- (void)removeCollectionFooterControllers:(NSArray*)controllers animated:(BOOL)animated{
    NSIndexSet* indexes = [[self mutableCollectionFooterControllers]indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [controllers containsObject:obj];
    }];
    [self removeCollectionHeaderControllersAtIndexes:indexes animated:animated];
}

- (void)insertCollectionFooterControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [[self mutableCollectionFooterControllers]insertObjects:controllers atIndexes:indexes];
    [super insertControllers:controllers atIndexes:[self indexesForCollectionFooterIndexes:indexes] animated:animated];
}

- (void)removeCollectionFooterControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    NSMutableIndexSet* mi = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if(idx != NSNotFound){
            [mi addIndex:idx];
        }
    }];
    
    [[self mutableCollectionFooterControllers]removeObjectsAtIndexes:mi];
    [super removeControllersAtIndexes:[self indexesForCollectionFooterIndexes:mi] animated:animated];
}

- (void)setupCollectionControllersByUpdatingCollectionController:(BOOL)updateCollectionControllers{
    
    if(updateCollectionControllers){
        [self removeAllCollectionControllersAnimated:YES];
    }
    
    CKWeakRef* weak = [CKWeakRef weakRefWithObject:self];
    
    [self beginBindingsContextWithScope:@"CKCollectionSection"];
    [self.collection bindEvent:CKCollectionBindingEventAll executeBlockImmediatly:updateCollectionControllers withBlock:^(CKCollectionBindingEvents event, NSArray *objects, NSIndexSet *indexes) {
        switch(event){
            case CKCollectionBindingEventInsertion:{
                [weak.object handleInsertionOfObjects:objects atIndexes:indexes];
                break;
            }
            case CKCollectionBindingEventRemoval:{
                [weak.object removeCollectionControllersAtIndexes:indexes animated:YES];
                break;
            }
        }
    }];
    
    
    [self endBindingsContext];
}

- (void)handleInsertionOfObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes{
    NSArray* indexPaths = [self indexPathsForIndexes:[self indexesForCollectionIndexes:indexes]];
    NSMutableArray* controllers = [NSMutableArray array];
    for(int i =0; i< objects.count; ++i){
        id object = objects[i];
        NSIndexPath* indexPath = indexPaths[i];
        CKReusableViewController* controller = [self.factory controllerForObject:object indexPath:indexPath containerController:self.containerViewController];
         NSAssert(controller,@"Unable to create a controller from the specified factory for object %@",object);
        [controllers addObject:controller];
    }
    [self insertCollectionControllers:controllers atIndexes:indexes animated:YES];
}

- (void)clearCollectionBindings{
    [self clearBindingsContextWithScope:@"CKCollectionSection"];
}

- (void)removeAllCollectionControllersAnimated:(BOOL)animated{
    [self removeCollectionControllersAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,self.mutableCollectionControllers.count)] animated:animated];
}

- (void)insertCollectionControllers:(NSArray*)controllers atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [[self mutableCollectionControllers]insertObjects:controllers atIndexes:indexes];
    [super insertControllers:controllers atIndexes:[self indexesForCollectionIndexes:indexes] animated:animated];
}

- (void)removeCollectionControllersAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [[self mutableCollectionControllers]removeObjectsAtIndexes:indexes];
    [super removeControllersAtIndexes:[self indexesForCollectionIndexes:indexes] animated:animated];
}


- (void)fetchNextPageFromIndex:(NSInteger)index{
    if(self.collection.isFetching)
        return;
    
    NSInteger pageSize = 20;
    if(index >= self.collection.count - pageSize){
        [self.collection fetchRange:NSMakeRange(self.collection.count, pageSize)];
    }
}

- (void)sectionContainerDelegate:(UIViewController<CKSectionContainerDelegate>*)sectionContainerDelegate willRemoveControllerAtIndex:(NSInteger)index{
    NSInteger originalIndex = index;
    
    if(index < self.collectionHeaderControllers.count){
        [[self mutableCollectionHeaderControllers] removeObjectAtIndex:index];
    }else if(index < (self.collectionControllers.count + self.collectionHeaderControllers.count)){
        [self clearCollectionBindings];
        index -= self.collectionHeaderControllers.count;
        [self.collection removeObjectAtIndex:index];
        [[self mutableCollectionControllers] removeObjectAtIndex:index];
        [self setupCollectionControllersByUpdatingCollectionController:NO];
    }else{
        index -= (self.collectionHeaderControllers.count + self.collectionControllers.count);
        [[self mutableCollectionFooterControllers] removeObjectAtIndex:index];
    }
    
    [super sectionContainerDelegate:sectionContainerDelegate willRemoveControllerAtIndex:originalIndex];
    
}

- (void)sectionContainerDelegate:(UIViewController<CKSectionContainerDelegate>*)sectionContainerDelegate didMoveControllerAtIndex:(NSInteger)from toIndex:(NSInteger)to
{
    NSInteger originalFrom = from;
    NSInteger originalTo = to;
    
    if(from < (self.collectionControllers.count + self.collectionHeaderControllers.count)
       && to < (self.collectionControllers.count + self.collectionHeaderControllers.count)){
        from -= self.collectionHeaderControllers.count;
        to -= self.collectionHeaderControllers.count;
        
        CKReusableViewController* controller = [[[self mutableCollectionControllers] objectAtIndex:from]retain];
        id object = [[self.collection objectAtIndex:from]retain];
        
        [self clearCollectionBindings];
        
        [self.collection removeObjectAtIndex:from];
        [[self mutableCollectionControllers] removeObjectAtIndex:from];
            
        [self.collection insertObject:object atIndex:to];
        [[self mutableCollectionControllers] insertObject:controller atIndex:to];
        
        [controller release];
        [object release];
        
        [self setupCollectionControllersByUpdatingCollectionController:NO];
    }
    
    [super sectionContainerDelegate:sectionContainerDelegate didMoveControllerAtIndex:originalFrom toIndex:originalTo];
}

- (NSRange)rangeForCollectionControllers{
    return NSMakeRange(self.collectionHeaderControllers.count, self.collectionControllers.count);
}

@end
