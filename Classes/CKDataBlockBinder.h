//
//  CKDataBlockBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-17.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^CKDataExecutionBlock)(id value);
@interface CKDataBlockBinder : NSObject {
	id instance;
	NSString* keyPath;
	CKDataExecutionBlock executionBlock;
	BOOL binded;
}

@property (nonatomic, assign) id instance;
@property (nonatomic, retain) NSString* keyPath;
@property (nonatomic, copy)   CKDataExecutionBlock executionBlock;

+(CKDataBlockBinder*) dataBlockBinder:(id)instance keyPath:(NSString*)keyPath executionBlock:(CKDataExecutionBlock)executionBlock;
- (void) bind;
-(void)unbind;

@end
