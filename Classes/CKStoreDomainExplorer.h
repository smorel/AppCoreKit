//
//  CKStoreDomainExplorer.h
//  Express
//
//  Created by Oli Kenobi on 10-01-24.
//  Copyright 2010 Kenobi Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CKStore.h>

@interface CKStoreDomainExplorer : UITableViewController {
	NSString *_domain;
	
	NSMutableArray *_items;
}

@property (retain) NSString *domain;
@property (retain) NSMutableArray *items;

- (id)initWithDomain:(NSString *)domain;
- (id)initWithItems:(NSMutableArray *)items;

@end
