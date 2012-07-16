//
//  CKDataBinder.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"
#import "CKWeakRef.h"


/** TODO
 */
@interface CKDataBinder : CKBinding {
	NSString* keyPath1;
	NSString* keyPath2;
	BOOL binded;
}

@property (nonatomic, retain) NSString *keyPath1;
@property (nonatomic, retain) NSString *keyPath2;
@property (nonatomic, assign) id instance1;
@property (nonatomic, assign) id instance2;

@end
