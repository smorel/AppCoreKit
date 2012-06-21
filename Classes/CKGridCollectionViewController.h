//
//  CKGridCollectionViewController.h
//  CloudKit
//
//  Created by Martin Dufort on 12-05-14.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableCollectionViewController.h"

@interface CKGridCollectionViewController : CKTableCollectionViewController
@property(nonatomic,assign) CGSize size;

- (CKCollectionCellController*)subControllerForRow:(NSInteger)row column:(NSInteger)column;

@end
