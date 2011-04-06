//
//  CKViewDataBinder.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKBinding.h"

@interface CKUIViewDataBinder : NSObject<CKBinding>{
	UIControlEvents controlEvents;
	NSString* keyPath;
	id target;
	NSString* targetKeyPath;
	
	//Internal
	UIControl* control;
	BOOL binded;
}

@property (nonatomic, retain) NSString *keyPath;
@property (nonatomic, assign) id target;
@property (nonatomic, retain) NSString *targetKeyPath;
@property (nonatomic, assign) UIControlEvents controlEvents;
@property (nonatomic, retain) UIControl *control;

@end