//
//  CKFormTableViewController_private.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-11-28.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

@interface CKFormTableViewController()
@property (nonatomic,retain, readwrite) NSMutableArray* sections;
@property (nonatomic,readwrite) BOOL reloading;
@property (nonatomic, assign) BOOL tableViewHasBeenReloaded;
@end