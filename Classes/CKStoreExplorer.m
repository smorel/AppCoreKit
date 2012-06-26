//
//  CKStoreExplorer.m
//  Express
//
//  Created by Oli Kenobi on 10-01-24.
//  Copyright 2010 Kenobi Studios. All rights reserved.
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


/**
 */
@interface CKStoreDomainExplorer : CKFormTableViewController 

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
@interface CKStoreItemExplorer : CKFormTableViewController 

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
    
    NSMutableArray* cellControllers = [NSMutableArray array];
    for (NSString *domain in domains) {
        //CKStore *store = [CKStore storeWithDomainName:domain];
        CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:domain action:^(CKTableViewCellController* controller){
            CKStoreDomainExplorer *domainExplorer = [[CKStoreDomainExplorer alloc] initWithDomain:domain];
            [self.navigationController pushViewController:domainExplorer animated:YES];
            [domainExplorer release];
        }];
        [cellControllers addObject:cellController];
    }
    [self addSections:[NSArray arrayWithObject:[CKFormSection sectionWithCellControllers:cellControllers]]];
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
    NSMutableArray* cellControllers = [NSMutableArray array];
    for(CKItem* item in items){
        CKAttribute* typeAttribute = [item attributeNamed:@"@class" createIfNotFound:NO];
        CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:typeAttribute ? 
                                                                                                       [NSString stringWithFormat:@"[%@] %@",typeAttribute.value,item.name] :item.name 
                                                                                              subtitle:[NSString stringWithFormat:@"%@", item.createdAt]  
                                                                                                action:^(CKTableViewCellController* controller){
                                                                                                    CKStoreItemExplorer *itemExplorer = [[[CKStoreItemExplorer alloc] initWithItem:item]autorelease];
                                                                                                    [self.navigationController pushViewController:itemExplorer animated:YES];
                                                                                                }];
        [cellControllers addObject:cellController];
    }
    [self addSections:[NSArray arrayWithObject:[CKFormSection sectionWithCellControllers:cellControllers]]];
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
    
    NSMutableArray* cellControllers = [NSMutableArray array];
    
    CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:@"item address" subtitle:[NSString stringWithFormat:@"%p",item] action:nil];
    [cellControllers addObject:cellController];
    
    for(CKAttribute* attribute in [item.attributes allObjects]){
        if(attribute.value != nil){
            CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:attribute.name subtitle:attribute.value action:nil];
            [cellControllers addObject:cellController];
        }
        else{
            CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:attribute.name subtitle:[NSString stringWithFormat:@"%d",[attribute.itemReferences count]] action:^(CKTableViewCellController* controller){
                CKStoreDomainExplorer* domainController = [[[CKStoreDomainExplorer alloc]initWithItems:[NSMutableArray arrayWithArray:attribute.items]]autorelease];
                domainController.title = attribute.name;
                [self.navigationController pushViewController:domainController animated:YES];
            }];
            [cellControllers addObject:cellController];
        }
    }
    [self addSections:[NSArray arrayWithObject:[CKFormSection sectionWithCellControllers:cellControllers]]];
    
    return self;
}

#pragma mark Table view methods



@end
