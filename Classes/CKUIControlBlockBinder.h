//
//  CKViewExecutionBlock.h
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"
#import "MAZeroingWeakRef.h"

typedef void(^CKUIControlBlock)();


@interface CKUIControlBlockBinder : NSObject<CKBinding>{
	UIControlEvents controlEvents;
	
	//We can use block or target/selector
	CKUIControlBlock block;
	MAZeroingWeakRef* targetRef;
	SEL selector;
	
	MAZeroingWeakRef* controlRef;
	BOOL binded;
}

@property (nonatomic, assign) UIControlEvents controlEvents;
@property (nonatomic, copy) CKUIControlBlock block;
@property (nonatomic, assign) SEL selector;

- (void)setTarget:(id)instance;
- (void)setControl:(UIControl*)control;

@end
