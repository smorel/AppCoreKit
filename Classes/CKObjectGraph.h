//
//  CKObjectGraph.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCascadingTree.h"


@interface CKObjectGraph : CKCascadingTree

+ (CKObjectGraph*)objectGraphWithContentOfFileNamed:(NSString*)name;
- (id)objectWithUniqueId:(NSString*)uniqueId;

@end
