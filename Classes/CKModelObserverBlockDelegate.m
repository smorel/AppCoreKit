//
//  CKModelObserverBlockDelegate.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObserverBlockDelegate.h"


@implementation CKModelObserverBlockDelegate

@synthesize insertAnimationBlock;
@synthesize removeAnimationBlock;
@synthesize moveAnimationBlock;
@synthesize insertBlock;
@synthesize removeBlock;
@synthesize moveBlock;
@synthesize clearAllBlock;
@synthesize preChangeNotificationBlock;
@synthesize postChangeNotificationBlock;

+ (CKModelObserverBlockDelegate*)delegate{
	return [[[CKModelObserverBlockDelegate alloc]init]autorelease];
}

- (void)dealloc{
	self.insertAnimationBlock = nil;
	self.removeAnimationBlock = nil;
	self.moveAnimationBlock = nil;
	self.insertBlock = nil;
	self.removeBlock = nil;
	self.moveBlock = nil;
	self.clearAllBlock = nil;
	self.preChangeNotificationBlock = nil;
	self.postChangeNotificationBlock = nil;
	[super dealloc];
}

- (void)modelObserverWillChange:(CKModelObserver*)observer{
	if(preChangeNotificationBlock){
		preChangeNotificationBlock(observer);
	}
}

- (void)modelObserverDidChange:(CKModelObserver*)observer{
	if(postChangeNotificationBlock){
		postChangeNotificationBlock(observer);
	}
}

- (void)modelObserver:(CKModelObserver*)observer animateInsertCommand:(CKModelObserverInsertCommand*)command{
	if(insertAnimationBlock){
		insertAnimationBlock(command);
	}
	else{
		[command animationEnded];
	}
}

- (void)modelObserver:(CKModelObserver*)observer animateRemoveCommand:(CKModelObserverRemoveCommand*)command{
	if(removeAnimationBlock){
		removeAnimationBlock(command);
	}
	else{
		[command animationEnded];
	}
}

- (void)modelObserver:(CKModelObserver*)observer animateMoveCommand:(CKModelObserverMoveCommand*)command{
	if(moveAnimationBlock){
		moveAnimationBlock(command);
	}
	else{
		[command animationEnded];
	}
}

- (void)modelObserver:(CKModelObserver*)observer executeInsertCommand:(CKModelObserverInsertCommand*)command{
	if(insertBlock){
		insertBlock(command);
	}
	else {
		NSAssert(NO,@"insertBlock not defined for the delegate");
	}
}

- (void)modelObserver:(CKModelObserver*)observer executeRemoveCommand:(CKModelObserverRemoveCommand*)command{
	if(removeBlock){
		removeBlock(command);
	}
	else {
		NSAssert(NO,@"removeBlock not defined for the delegate");
	}
}

- (void)modelObserver:(CKModelObserver*)observer executeMoveCommand:(CKModelObserverMoveCommand*)command{
	if(moveBlock){
		moveBlock(command);
	}
	else {
		NSAssert(NO,@"moveBlock not defined for the delegate");
	}
}

- (void)modelObserverClearAll:(CKModelObserver*)observer{
	if(clearAllBlock){
		clearAllBlock(observer);
	}
	else {
		NSAssert(NO,@"clearAllBlock not defined for the delegate");
	}
}


@end
