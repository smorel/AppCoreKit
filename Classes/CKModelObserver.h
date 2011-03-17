//
//  CKModelObserver.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <CloudKit/CKFeedSource.h>
#import <QuartzCore/QuartzCore.h>

@class CKModelObserver;

@interface CKModelObserverCommand : NSObject{
	int index;
	id model;
	UIImageView* imageView;
	CKModelObserver* modelObserver;
}

@property (nonatomic, assign) int index;
@property (nonatomic, retain) id model;
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, assign) CKModelObserver* modelObserver;

- (void)animationEnded;

@end


//

@interface CKModelObserverInsertCommand : CKModelObserverCommand{
}
@end

@interface CKModelObserverRemoveCommand : CKModelObserverCommand{
}
@end

@interface CKModelObserverMoveCommand : CKModelObserverCommand{
	int initialIndex;
}
@property (nonatomic, assign) int initialIndex;
@end
	

//

@protocol CKModelObserverDelegate
- (void)modelObserverWillChange:(CKModelObserver*)observer;
- (void)modelObserverDidChange:(CKModelObserver*)observer;
- (void)modelObserver:(CKModelObserver*)observer animateInsertCommand:(CKModelObserverInsertCommand*)command;
- (void)modelObserver:(CKModelObserver*)observer animateRemoveCommand:(CKModelObserverRemoveCommand*)command;
- (void)modelObserver:(CKModelObserver*)observer animateMoveCommand:(CKModelObserverMoveCommand*)command;
- (void)modelObserver:(CKModelObserver*)observer executeInsertCommand:(CKModelObserverInsertCommand*)command;
- (void)modelObserver:(CKModelObserver*)observer executeRemoveCommand:(CKModelObserverRemoveCommand*)command;
- (void)modelObserver:(CKModelObserver*)observer executeMoveCommand:(CKModelObserverMoveCommand*)command;
- (void)modelObserverClearAll:(CKModelObserver*)observer;
@end


//

typedef enum{
	CKModelObserverStateAnimating,
	CKModelObserverStateExecuting,
	CKModelObserverStateObserving,
	CKModelObserverStateWaiting
}CKModelObserverState;
							
@interface CKModelObserver : NSObject{
	NSMutableDictionary* toExecuteList;
	NSMutableDictionary* changeList;
	id<CKDocument> document;
	NSString* objectsKey;
	id delegate;
	
	CKModelObserverState state;
}

@property (nonatomic, retain, readonly) id<CKDocument> document;
@property (nonatomic, retain, readonly) NSString* objectsKey;
@property (nonatomic, assign) id delegate;

- (id)initWithDocument:(id<CKDocument>) document key:(NSString*)key delegate:(id)thedelegate;
- (void)executeNow;

@end


//

@interface CKModelObserver (CKFeedSourceHelper)
- (void)initWithFeedSource:(CKFeedSource *)source delegate:(id)delegate;
@end

