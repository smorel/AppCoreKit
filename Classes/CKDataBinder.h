//
//  CKDataBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"
#import "MAZeroingWeakRef.h"

@interface CKDataBinder : NSObject<CKBinding> {
	MAZeroingWeakRef* instance1Ref;
	NSString* keyPath1;
	MAZeroingWeakRef* instance2Ref;
	NSString* keyPath2;
	BOOL binded;
}

@property (nonatomic, retain) NSString *keyPath1;
@property (nonatomic, retain) NSString *keyPath2;

- (void)setInstance1:(id)instance;
- (void)setInstance2:(id)instance;

@end
