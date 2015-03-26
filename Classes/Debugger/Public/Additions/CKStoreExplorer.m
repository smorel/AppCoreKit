//
//  CKStoreExplorer.m
//  AppCoreKit
//
//  Created by Oli Kenobi.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKStoreExplorer.h"
#import "CKAttribute.h"
#import "CKItemAttributeReference.h"
#import "CKStore.h"
#import "CKItem.h"
#import "CKLocalization.h"
#import "CKCoreDataManager.h"
#import "CKDomain.h"
#import "CKItem.h"
#import "CKStandardContentViewController.h"


/**
 */
@interface CKStoreDomainExplorer : CKTableViewController

///-----------------------------------
/// @name Initializing a CKStore Domain Explorer
///-----------------------------------

/**
 */
- (id)initWithDomain:(NSString *)domain;

/**
 */
- (id)initWithItems:(NSMutableArray *)items;

@end



/**
 */
@interface CKStoreItemExplorer : CKTableViewController

///-----------------------------------
/// @name Initializing a CKStore item Explorer
///-----------------------------------

/**
 */
- (id)initWithItem:(CKItem *)item;

@end


@implementation CKStoreExplorer

- (void)setupWithDomains:(NSArray *)domains{
    self.title = @"Domains";
    
    NSMutableArray* controllers = [NSMutableArray array];
    for (NSString *domain in domains) {
        //CKStore *store = [CKStore storeWithDomainName:domain];
        CKStandardContentViewController* controller = [CKStandardContentViewController controllerWithTitle:domain action:^(CKStandardContentViewController* controller){
            CKStoreDomainExplorer *domainExplorer = [[CKStoreDomainExplorer alloc] initWithDomain:domain];
            [self.navigationController pushViewController:domainExplorer animated:YES];
            [domainExplorer release];
        }];
        [controllers addObject:controller];
    }
    [self addSection:[CKSection sectionWithControllers:controllers] animated:NO];
}

- (id)init{
    self = [super initWithStyle:UITableViewStylePlain];
    
    NSMutableArray* domains = [NSMutableArray array];
    NSArray* objects = [[[CKStore storeCoreDataManager]objectContext]fetchObjectsForEntityForName:@"CKDomain" predicate:nil sortedBy:nil range:NSMakeRange(0, INT_MAX)];
    for(CKDomain* domain in objects){
        if(![domain.name isEqualToString:@"whatever"]){
            [domains addObject:domain.name];
        }
    }
    
    [self setupWithDomains:domains];
    
    return self;
}

- (id)initWithDomains:(NSArray *)domains {
    self = [super initWithStyle:UITableViewStylePlain];
    [self setupWithDomains:domains];
    return self;
}

@end

@implementation CKStoreDomainExplorer

- (void)setupWithItems:(NSArray*)items{
    NSMutableArray* controllers = [NSMutableArray array];
    for(CKItem* item in items){
        CKAttribute* typeAttribute = [item attributeNamed:@"@class" createIfNotFound:NO];
        CKStandardContentViewController* controller = [CKStandardContentViewController controllerWithTitle:typeAttribute ?
                                                       [NSString stringWithFormat:@"[%@] %@",typeAttribute.value,item.name] :item.name
                                                                                                  subtitle:[NSString stringWithFormat:@"%@", item.createdAt]
                                                                                                    action:^(CKStandardContentViewController* controller){
            CKStoreItemExplorer *itemExplorer = [[[CKStoreItemExplorer alloc] initWithItem:item]autorelease];
            [self.navigationController pushViewController:itemExplorer animated:YES];
        }];
        [controllers addObject:controller];
    }
    [self addSection:[CKSection sectionWithControllers:controllers] animated:NO];
}

- (id)initWithDomain:(NSString *)domain {
    self = [super initWithStyle:UITableViewStylePlain];
    self.title = @"Items";
    
    CKStore *store = [CKStore storeWithDomainName:domain];
    NSArray* items = [store fetchItems];
    [self setupWithItems:items];
    
    return self;
}

- (id)initWithItems:(NSMutableArray *)theitems{
	self = [super initWithStyle:UITableViewStylePlain];
    [self setupWithItems:theitems];
    return self;
}

@end


@implementation CKStoreItemExplorer

- (id)initWithItem:(CKItem *)item {
    self = [super initWithStyle:UITableViewStylePlain];
	self.title = @"Attributes";
    
    NSMutableArray* controllers = [NSMutableArray array];
    
    CKStandardContentViewController* controller = [CKStandardContentViewController controllerWithTitle:@"item address" subtitle:[NSString stringWithFormat:@"%p",item] action:nil];
    [controllers addObject:controller];
    
    for(CKAttribute* attribute in [item.attributes allObjects]){
        if(attribute.value != nil){
            CKStandardContentViewController* controller = [CKStandardContentViewController controllerWithTitle:attribute.name subtitle:attribute.value action:nil];
            [controllers addObject:controller];
        }
        else{
            CKStandardContentViewController* controller = [CKStandardContentViewController controllerWithTitle:attribute.name subtitle:[NSString stringWithFormat:@"%lu",(unsigned long)[attribute.itemReferences count]] action:^(CKStandardContentViewController* controller){
                CKStoreDomainExplorer* domainController = [[[CKStoreDomainExplorer alloc]initWithItems:[NSMutableArray arrayWithArray:attribute.items]]autorelease];
                domainController.title = attribute.name;
                [self.navigationController pushViewController:domainController animated:YES];
            }];
            [controllers addObject:controller];
        }
    }
    [self addSection:[CKSection sectionWithControllers:controllers] animated:NO];
    
    return self;
}

#pragma mark Table view methods



@end
