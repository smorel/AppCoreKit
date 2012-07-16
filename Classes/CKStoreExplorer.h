//
//  CKStoreExplorer.h
//  CloudKit
//
//  Created by Oli Kenobi.
//  Copyright 2010 Kenobi Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKStore.h"
#import "CKItem.h"
#import "CKFormTableViewController.h"


/** TODO
 */
@interface CKStoreExplorer : CKFormTableViewController
- (id)initWithDomains:(NSArray *)domains;
@end



/** TODO
 */
@interface CKStoreDomainExplorer : CKFormTableViewController 

- (id)initWithDomain:(NSString *)domain;
- (id)initWithItems:(NSMutableArray *)items;

@end



/** TODO
 */
@interface CKStoreItemExplorer : CKFormTableViewController 
- (id)initWithItem:(CKItem *)item;
@end
