//
//  CKStoreItemExplorer.h
//  Express
//
//  Created by Oli Kenobi on 10-01-24.
//  Copyright 2010 Kenobi Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKItem.h"


/** TODO
 */
@interface CKStoreItemExplorer : UITableViewController {
	CKItem *_item;
	NSMutableArray *_attributes;
}

@property (retain) CKItem *item;

- (id)initWithItem:(CKItem *)item;

@end
