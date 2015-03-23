//
//  CKReusableViewControllerFactory.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewControllerFactory.h"
#import "CKContainerViewController.h"

@interface CKReusableViewControllerFactoryItem : NSObject

+ (CKReusableViewControllerFactoryItem*)itemWithPredicate:(NSPredicate*)predicate
                                          factory:(CKReusableViewController*(^)(id object, NSIndexPath* indexPath))block;


@property(nonatomic,copy)   CKReusableViewController*(^factory)(id object, NSIndexPath* indexPath);
@property(nonatomic,retain) NSPredicate* predicate;

@end


@implementation CKReusableViewControllerFactoryItem

- (void)dealloc{
    [_factory release];
    [_predicate release];
    [super dealloc];
}

+ (CKReusableViewControllerFactoryItem*)itemWithPredicate:(NSPredicate*)predicate
                                          factory:(CKReusableViewController*(^)(id object, NSIndexPath* indexPath))factory{
    CKReusableViewControllerFactoryItem* item = [[[CKReusableViewControllerFactoryItem alloc]init]autorelease];
    item.predicate = predicate;
    item.factory = factory;
    return item;
}

@end


@interface CKReusableViewControllerFactory()
@property(nonatomic,retain) NSMutableArray* items;
@end

@implementation CKReusableViewControllerFactory

- (void)dealloc{
    [_items release];
    [super dealloc];
}

+ (CKReusableViewControllerFactory*)factory{
    return [[[CKReusableViewControllerFactory alloc]init]autorelease];
}

- (void)registerFactoryForObjectOfClass:(Class)type
                                factory:(CKReusableViewController*(^)(id object, NSIndexPath* indexPath))factory{
    [self registerFactoryWithPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:type];
    }] factory:factory];
}

- (void)registerFactoryWithPredicate:(NSPredicate*)predicate
                             factory:(CKReusableViewController*(^)(id object, NSIndexPath* indexPath))factory{
    CKReusableViewControllerFactoryItem* item = [CKReusableViewControllerFactoryItem itemWithPredicate:predicate factory:factory];
    if(!self.items) { self.items = [NSMutableArray array]; }
    [self.items addObject:item];
}

- (CKReusableViewControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath containerController:(UIViewController*)containerController{
    for(CKReusableViewControllerFactoryItem* item in _items){
        if([item.predicate evaluateWithObject:object]){
            return item;
        }
    }
    return nil;
}

- (CKReusableViewController*)controllerForObject:(id)object indexPath:(NSIndexPath*)indexPath containerController:(UIViewController*)containerController{
    CKReusableViewControllerFactoryItem* item = [self factoryItemForObject:object atIndexPath:indexPath containerController:containerController];
    if(!item)
        return nil;
    
    CKReusableViewController* controller = item.factory(object,indexPath);
    [controller setContainerViewController:containerController];
    return controller;
}

@end
