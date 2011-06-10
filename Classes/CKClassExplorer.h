//
//  CKClassExplorer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectTableViewController.h"
#import "CKDocumentArray.h"
#import "CKCallback.h"


@interface CKClassExplorer : CKObjectTableViewController {
	CKDocumentArray* _classesCollection;
	id _userInfo;
}
@property(nonatomic,retain)id userInfo;

- (id)initWithBaseClass:(Class)type;

@end
