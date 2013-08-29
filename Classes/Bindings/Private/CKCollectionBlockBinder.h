//
//  CKCollectionBlockBinder.h
//  AppCoreKit
//
//  Created by Martin Dufort on 12-09-13.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKBinding.h"
#import "NSObject+Bindings.h"

typedef void(^CKCollectionBlockBinderBlock)(CKCollectionBindingEvents event, NSArray* objects, NSIndexSet* indexes);

@interface CKCollectionBlockBinder : CKBinding
@property (nonatomic,assign) CKCollectionBindingEvents events;
@property (nonatomic,assign) CKCollection* instance;
@property (nonatomic,copy) CKCollectionBlockBinderBlock block;
@end
