//
//  CKViewControllerFactory.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKViewControllerFactory.h"
#import "CKContainerViewController.h"

@interface CKViewControllerFactoryItem : NSObject

+ (CKViewControllerFactoryItem*)itemWithPredicate:(NSPredicate*)predicate
                                          factory:(CKResusableViewController*(^)(id object, NSIndexPath* indexPath))block;


@property(nonatomic,copy)   CKResusableViewController*(^factory)(id object, NSIndexPath* indexPath);
@property(nonatomic,retain) NSPredicate* predicate;

@end


@implementation CKViewControllerFactoryItem

- (void)dealloc{
    [_factory release];
    [_predicate release];
    [super dealloc];
}

+ (CKViewControllerFactoryItem*)itemWithPredicate:(NSPredicate*)predicate
                                          factory:(CKResusableViewController*(^)(id object, NSIndexPath* indexPath))factory{
    CKViewControllerFactoryItem* item = [[[CKViewControllerFactoryItem alloc]init]autorelease];
    item.predicate = predicate;
    item.factory = factory;
    return item;
}

@end


@interface CKViewControllerFactory()
@property(nonatomic,retain) NSMutableArray* items;
@end

@implementation CKViewControllerFactory

- (void)dealloc{
    [_items release];
    [super dealloc];
}

+ (CKViewControllerFactory*)factory{
    return [[[CKViewControllerFactory alloc]init]autorelease];
}

- (void)registerFactoryForObjectOfClass:(Class)type
                                factory:(CKResusableViewController*(^)(id object, NSIndexPath* indexPath))factory{
    [self registerFactoryWithPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:type];
    }] factory:factory];
}

- (void)registerFactoryWithPredicate:(NSPredicate*)predicate
                             factory:(CKResusableViewController*(^)(id object, NSIndexPath* indexPath))factory{
    CKViewControllerFactoryItem* item = [CKViewControllerFactoryItem itemWithPredicate:predicate factory:factory];
    if(!self.items) { self.items = [NSMutableArray array]; }
    [self.items addObject:item];
}

- (CKViewControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath containerController:(UIViewController*)containerController{
    for(CKViewControllerFactoryItem* item in _items){
        if([item.predicate evaluateWithObject:object]){
            return item;
        }
    }
    return nil;
}

- (CKResusableViewController*)controllerForObject:(id)object indexPath:(NSIndexPath*)indexPath containerController:(UIViewController*)containerController{
    CKViewControllerFactoryItem* item = [self factoryItemForObject:object atIndexPath:indexPath containerController:containerController];
    if(!item)
        return nil;
    
    CKResusableViewController* controller = item.factory(object,indexPath);
    [controller setContainerViewController:containerController];
    return controller;
}

@end
