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

- (void)lanchAnimation;
- (void)updateSubControllers;
- (void)animationEnded;

@end

@class CKModelObserverInsertCommand;
typedef void(^CKModelObserverInsertCommandBlock)(CKModelObserverInsertCommand* command);

@interface CKModelObserverInsertCommand : CKModelObserverCommand{
}
@end

@class CKModelObserverRemoveCommand;
typedef void(^CKModelObserverRemoveCommandBlock)(CKModelObserverRemoveCommand* command);

@interface CKModelObserverRemoveCommand : CKModelObserverCommand{
}
@end

@class CKModelObserverMoveCommand;
typedef void(^CKModelObserverMoveCommandBlock)(CKModelObserverMoveCommand* command);

@interface CKModelObserverMoveCommand : CKModelObserverCommand{
	int initialIndex;
}
@property (nonatomic, assign) int initialIndex;
@end
	
typedef enum{
	CKModelObserverStateAnimating,
	CKModelObserverStateExecuting,
	CKModelObserverStateObserving,
	CKModelObserverStateWaiting
}CKModelObserverState;
							  
@class CKModelObserver;
typedef void(^CKModelObserverBlock)(CKModelObserver* observer);
@interface CKModelObserver : NSObject{
	NSMutableDictionary* toExecuteList;
	NSMutableDictionary* changeList;
	id<CKDocument> document;
	NSString* objectsKey;
	
	CKModelObserverBlock preChangeNotificationBlock;
	CKModelObserverBlock postChangeNotificationBlock;
	CKModelObserverBlock clearAllBlock;
	CKModelObserverInsertCommandBlock insertAnimationBlock;
	CKModelObserverRemoveCommandBlock removeAnimationBlock;
	CKModelObserverMoveCommandBlock moveAnimationBlock;
	CKModelObserverInsertCommandBlock insertBlock;
	CKModelObserverRemoveCommandBlock removeBlock;
	CKModelObserverMoveCommandBlock moveBlock;
	
	CKModelObserverState state;
}

@property (nonatomic, retain) NSMutableDictionary *changeList;
@property (nonatomic, retain) NSMutableDictionary *toExecuteList;
@property (nonatomic, copy) CKModelObserverBlock clearAllBlock;
@property (nonatomic, copy) CKModelObserverInsertCommandBlock insertAnimationBlock;
@property (nonatomic, copy) CKModelObserverRemoveCommandBlock removeAnimationBlock;
@property (nonatomic, copy) CKModelObserverMoveCommandBlock moveAnimationBlock;
@property (nonatomic, copy) CKModelObserverInsertCommandBlock insertBlock;
@property (nonatomic, copy) CKModelObserverRemoveCommandBlock removeBlock;
@property (nonatomic, copy) CKModelObserverMoveCommandBlock moveBlock;
@property (nonatomic, copy) CKModelObserverBlock preChangeNotificationBlock;
@property (nonatomic, copy) CKModelObserverBlock postChangeNotificationBlock;
@property (nonatomic, retain, readonly) id<CKDocument> document;
@property (nonatomic, retain, readonly) NSString* objectsKey;

- (id)initWithDocument:(id<CKDocument>) document key:(NSString*)key;
- (void)executeNow;

@end


@interface CKModelObserver (CKFeedSourceHelper)
- (void)setDataSource:(CKFeedSource *)dataSource;
@end

