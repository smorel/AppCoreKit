//
//  CKViewExecutionBlock.h
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"
typedef void(^CKUIControlBlock)();


@interface CKUIControlBlockBinder : NSObject<CKBinding>{
	UIControlEvents controlEvents;
	
	//We can use block or target/selector
	CKUIControlBlock block;
	id target;
	SEL selector;
	
	UIControl* control;
	BOOL binded;
}

@property (nonatomic, assign) UIControlEvents controlEvents;
@property (nonatomic, copy) CKUIControlBlock block;
@property (nonatomic, retain) UIControl *control;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL selector;

@end
