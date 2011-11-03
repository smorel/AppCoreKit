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


@implementation CKStoreExplorer

- (void)setupWithDomains:(NSArray *)domains{
    self.title = @"Domains";
    
    NSMutableArray* cellDescriptors = [NSMutableArray array];
    for (NSString *domain in domains) {
        //CKStore *store = [CKStore storeWithDomainName:domain];
        CKFormCellDescriptor* desc = [CKFormCellDescriptor cellDescriptorWithTitle:domain action:^(CKTableViewCellController* controller){
            CKStoreDomainExplorer *domainExplorer = [[CKStoreDomainExplorer alloc] initWithDomain:domain];
            [self.navigationController pushViewController:domainExplorer animated:YES];
            [domainExplorer release];
        }];
        [cellDescriptors addObject:desc];
    }
    [self addSections:[NSArray arrayWithObject:[CKFormSection sectionWithCellDescriptors:cellDescriptors]]];
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
    NSMutableArray* cellDescriptors = [NSMutableArray array];
    for(CKItem* item in items){
        CKAttribute* typeAttribute = [item attributeNamed:@"@class" createIfNotFound:NO];
        CKFormCellDescriptor* desc = [CKFormCellDescriptor cellDescriptorWithTitle:typeAttribute ? [NSString stringWithFormat:@"[%@] %@",typeAttribute.value,item.name] :item.name 
                                                                          subtitle:[NSString stringWithFormat:@"%@", item.createdAt]  
                                                                            action:^(CKTableViewCellController* controller){
                                                                                CKStoreItemExplorer *itemExplorer = [[[CKStoreItemExplorer alloc] initWithItem:item]autorelease];
                                                                                [self.navigationController pushViewController:itemExplorer animated:YES];
                                                                                }];
        [cellDescriptors addObject:desc];
    }
    [self addSections:[NSArray arrayWithObject:[CKFormSection sectionWithCellDescriptors:cellDescriptors]]];
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
    
    NSMutableArray* cellDescriptors = [NSMutableArray array];
    
    CKFormCellDescriptor* desc = [CKFormCellDescriptor cellDescriptorWithTitle:@"item address" subtitle:[NSString stringWithFormat:@"%p",item] action:nil];
    [cellDescriptors addObject:desc];
    
    for(CKAttribute* attribute in [item.attributes allObjects]){
        if(attribute.value != nil){
            CKFormCellDescriptor* desc = [CKFormCellDescriptor cellDescriptorWithTitle:attribute.name subtitle:attribute.value action:nil];
            [cellDescriptors addObject:desc];
        }
        else{
            CKFormCellDescriptor* desc = [CKFormCellDescriptor cellDescriptorWithTitle:attribute.name subtitle:[NSString stringWithFormat:@"%d",[attribute.itemReferences count]] action:^(CKTableViewCellController* controller){
                CKStoreDomainExplorer* domainController = [[[CKStoreDomainExplorer alloc]initWithItems:[NSMutableArray arrayWithArray:attribute.items]]autorelease];
                domainController.title = attribute.name;
                [self.navigationController pushViewController:domainController animated:YES];
            }];
            [cellDescriptors addObject:desc];
        }
    }
    [self addSections:[NSArray arrayWithObject:[CKFormSection sectionWithCellDescriptors:cellDescriptors]]];
    
    return self;
}

#pragma mark Table view methods



@end
