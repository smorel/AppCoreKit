//
//  CKClassExplorer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "CKBindedTableViewController.h"
#import "CKArrayCollection.h"
#import "CKCallback.h"


/** TODO
 */
typedef enum CKClassExplorerType{
	CKClassExplorerTypeClasses,
	CKClassExplorerTypeInstances
}CKClassExplorerType;


/** TODO
 */
@interface CKClassExplorer : CKBindedTableViewController {
	CKArrayCollection* _classesCollection;
	id _userInfo;
	NSString* _className;
}
@property(nonatomic,retain)id userInfo;

- (id)initWithBaseClass:(Class)type;
- (id)initWithProtocol:(Protocol*)protocol;

@end
