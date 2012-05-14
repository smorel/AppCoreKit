//
//  CKGridCollection.h
//  CloudKit
//
//  Created by Martin Dufort on 12-05-14.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKArrayCollection.h"


@interface CKGridCollection : CKArrayCollection

@property(nonatomic,retain) CKCollection* collection;
@property(nonatomic,assign) CGSize size;

- (id)initWithCollection:(CKCollection*)collection size:(CGSize)size;

@end
