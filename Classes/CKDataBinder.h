//
//  CKDataBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"

@interface CKDataBinder : NSObject<CKBinding> {
	id instance1;
	NSString* keyPath1;
	id instance2;
	NSString* keyPath2;
	BOOL binded;
}

@property (nonatomic, assign) id instance1;
@property (nonatomic, retain) NSString *keyPath1;
@property (nonatomic, assign) id instance2;
@property (nonatomic, retain) NSString *keyPath2;

@end
