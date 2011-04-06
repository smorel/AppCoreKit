//
//  CKModelObserverBlockDelegate.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObserver.h"

typedef void(^CKModelObserverInsertCommandBlock)(CKModelObserverInsertCommand* command);
typedef void(^CKModelObserverRemoveCommandBlock)(CKModelObserverRemoveCommand* command);
typedef void(^CKModelObserverMoveCommandBlock)(CKModelObserverMoveCommand* command);
typedef void(^CKModelObserverBlock)(CKModelObserver* observer);

@interface CKModelObserverBlockDelegate : NSObject<CKModelObserverDelegate> {
	CKModelObserverBlock preChangeNotificationBlock;
	CKModelObserverBlock postChangeNotificationBlock;
	CKModelObserverBlock clearAllBlock;
	CKModelObserverInsertCommandBlock insertAnimationBlock;
	CKModelObserverRemoveCommandBlock removeAnimationBlock;
	CKModelObserverMoveCommandBlock moveAnimationBlock;
	CKModelObserverInsertCommandBlock insertBlock;
	CKModelObserverRemoveCommandBlock removeBlock;
	CKModelObserverMoveCommandBlock moveBlock;
}

@property (nonatomic, copy) CKModelObserverBlock clearAllBlock;
@property (nonatomic, copy) CKModelObserverInsertCommandBlock insertAnimationBlock;
@property (nonatomic, copy) CKModelObserverRemoveCommandBlock removeAnimationBlock;
@property (nonatomic, copy) CKModelObserverMoveCommandBlock moveAnimationBlock;
@property (nonatomic, copy) CKModelObserverInsertCommandBlock insertBlock;
@property (nonatomic, copy) CKModelObserverRemoveCommandBlock removeBlock;
@property (nonatomic, copy) CKModelObserverMoveCommandBlock moveBlock;
@property (nonatomic, copy) CKModelObserverBlock preChangeNotificationBlock;
@property (nonatomic, copy) CKModelObserverBlock postChangeNotificationBlock;

+ (CKModelObserverBlockDelegate*)delegate;

@end
