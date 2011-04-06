//
//  CKModelObserver.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObserver.h"

static int countCmd = 0;

@interface CKModelObserverCommand ()
- (void)lanchAnimation;
- (void)updateSubControllers;
@end

@implementation CKModelObserverCommand
@synthesize index;
@synthesize model;
@synthesize imageView;
@synthesize modelObserver;

- (id)init{
	[super init];
	++countCmd;
	return self;
}

- (void)dealloc{
	--countCmd;
	
	//Make sure we clear anims because anims retains command as a delegate
	if(self.imageView){
		[self.imageView.layer removeAllAnimations];
		[self.imageView removeFromSuperview];
	}
	
	self.model = nil;
	self.imageView = nil;
	self.modelObserver = nil;
	[super dealloc];
}

//If creating CAAnimation
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
	if(flag){
		//Make sure we clear anims because anims retains command as a delegate
		/*if(self.imageView){
			[self.imageView.layer removeAllAnimations];
			[self.imageView removeFromSuperview];
		}*/
		
		[self animationEnded];
	}
}

//If committing animations on UIView
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	if([finished boolValue]){
		//Make sure we clear anims because anims retains command as a delegate
		/*if(self.imageView){
			[self.imageView.layer removeAllAnimations];
			[self.imageView removeFromSuperview];
		}*/
		
		[self animationEnded];
	}
}

- (void)animationEnded{
	//Make sure we clear anims because anims retains command as a delegate
	/*if(self.imageView){
		[self.imageView.layer removeAllAnimations];
		[self.imageView removeFromSuperview];
	}*/
	
	[self.modelObserver performSelector:@selector(removeCommandForModel:) withObject:self.model];
}

- (void)lanchAnimation{
	NSAssert(NO,@"Base class implementation");
}

- (void)updateSubControllers{
	NSAssert(NO,@"Base class implementation");
}

@end;


@implementation CKModelObserverInsertCommand

- (void)lanchAnimation{
	if(self.modelObserver.delegate && [self.modelObserver.delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
		if([self.modelObserver.delegate respondsToSelector:@selector(modelObserver:animateInsertCommand:)]){
			[self.modelObserver.delegate performSelector:@selector(modelObserver:animateInsertCommand:) withObject:self.modelObserver withObject:self];
		}
		else{
			[self animationEnded];
		}
	}
	else{
		NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
	}
}

- (void)updateSubControllers{
	if(self.modelObserver.delegate && [self.modelObserver.delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
		if([self.modelObserver.delegate respondsToSelector:@selector(modelObserver:executeInsertCommand:)]){
			[self.modelObserver.delegate performSelector:@selector(modelObserver:executeInsertCommand:) withObject:self.modelObserver withObject:self];
		}
		else{
			NSAssert(NO,@"delegate do not implement modelObserver:executeInsertCommand:");
		}
	}
	else{
		NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
	}
}

@end;

@implementation CKModelObserverRemoveCommand

- (void)lanchAnimation{
	if(self.modelObserver.delegate && [self.modelObserver.delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
		if([self.modelObserver.delegate respondsToSelector:@selector(modelObserver:animateRemoveCommand:)]){
			[self.modelObserver.delegate performSelector:@selector(modelObserver:animateRemoveCommand:) withObject:self.modelObserver withObject:self];
		}
		else{
			[self animationEnded];
		}
	}
	else{
		NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
	}
}

- (void)updateSubControllers{
	if(self.modelObserver.delegate && [self.modelObserver.delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
		if([self.modelObserver.delegate respondsToSelector:@selector(modelObserver:executeRemoveCommand:)]){
			[self.modelObserver.delegate performSelector:@selector(modelObserver:executeRemoveCommand:) withObject:self.modelObserver withObject:self];
		}
		else{
			NSAssert(NO,@"delegate do not implement modelObserver:executeRemoveCommand:");
		}
	}
	else{
		NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
	}
}

@end;

@implementation CKModelObserverMoveCommand
@synthesize initialIndex;

- (void)lanchAnimation{
	if(self.modelObserver.delegate && [self.modelObserver.delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
		if([self.modelObserver.delegate respondsToSelector:@selector(modelObserver:animateMoveCommand:)]){
			[self.modelObserver.delegate performSelector:@selector(modelObserver:animateMoveCommand:) withObject:self.modelObserver withObject:self];
		}
		else{
			[self animationEnded];
		}
	}
	else{
		NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
	}
}

- (void)updateSubControllers{
	if(self.modelObserver.delegate && [self.modelObserver.delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
		if([self.modelObserver.delegate respondsToSelector:@selector(modelObserver:executeMoveCommand:)]){
			[self.modelObserver.delegate performSelector:@selector(modelObserver:executeMoveCommand:) withObject:self.modelObserver withObject:self];
		}
		else{
			NSAssert(NO,@"delegate do not implement modelObserver:executeMoveCommand:");
		}
	}
	else{
		NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
	}
}

@end;


@interface CKModelObserver ()
@property (nonatomic, retain) NSMutableDictionary *changeList;
@property (nonatomic, retain) NSMutableDictionary *toExecuteList;

@property (nonatomic, retain) id<CKDocument> document;
@property (nonatomic, retain) NSString* objectsKey;
@end

@implementation CKModelObserver
@synthesize changeList;
@synthesize document;
@synthesize objectsKey;
@synthesize toExecuteList;
@synthesize delegate;

- (void) dealloc{
	if(self.document){
		[self.document releaseObjectsForKey:self.objectsKey];
		[self.document removeObserver:self forKey:self.objectsKey];
	}
	
	self.changeList = nil;
	self.document = nil;
	self.objectsKey = nil;
	self.toExecuteList = nil;
	self.delegate = nil;
	[super dealloc];
}

- (id)init{
	[super init];
	self.changeList = [NSMutableDictionary dictionary];
	self.toExecuteList = [NSMutableDictionary dictionary];
	state = CKModelObserverStateWaiting;
	return self;
}

- (id)initWithDocument:(id<CKDocument>) theDocument key:(NSString*)key delegate:(id)thedelegate{
	[super init];
	self.delegate = thedelegate;
	if(self.document){
		[self.document releaseObjectsForKey:self.objectsKey];
		[self.document removeObserver:self forKey:self.objectsKey];
	}
	
	self.changeList = [NSMutableDictionary dictionary];
	self.toExecuteList = [NSMutableDictionary dictionary];
	state = CKModelObserverStateWaiting;
	
	self.document = theDocument;
	self.objectsKey = key;
	[self.document addObserver:self forKey:key];
	[self.document retainObjectsForKey:self.objectsKey];
	
	return self;
}

- (void)moveModel:(id)model fromIndex:(int)fromIndex toIndex:(int)toIndex{
	if(model == nil){
		NSLog(@"CKModelObserver Try to move a nil model Object. Ignoring this command");
		return;
	}
	
	CKModelObserverCommand* existingCommand = [changeList objectForKey:model];
	//Remove Previous Command if no move
	if(existingCommand && [existingCommand isKindOfClass:[CKModelObserverMoveCommand class]]){
		CKModelObserverMoveCommand* existingMoveCommand = (CKModelObserverMoveCommand*)existingCommand;
		existingMoveCommand.index = toIndex;
		[toExecuteList removeObjectForKey:model];
	}
	else if(existingCommand && [existingCommand isKindOfClass:[CKModelObserverInsertCommand class]]){
		CKModelObserverInsertCommand* insertCommand = (CKModelObserverInsertCommand*)existingCommand;
		insertCommand.index = toIndex;
		[toExecuteList removeObjectForKey:model];
	}
	else if(existingCommand){
		NSAssert(NO,@"This should not happend");
	}
	//Create MoveCommand
	else{
		CKModelObserverMoveCommand* moveCommand = [[[CKModelObserverMoveCommand alloc]init]autorelease];
		moveCommand.initialIndex = fromIndex;
		moveCommand.index = toIndex;
		moveCommand.model = model;
		moveCommand.modelObserver = self;
		[changeList setObject:moveCommand forKey:model];
	}
}

- (void)insertModel:(id)model atIndex:(int)index{
	if(model == nil){
		NSLog(@"CKModelObserver Try to insert a nil model Object. Ignoring this command");
		return;
	}
	
	CKModelObserverCommand* existingCommand = [changeList objectForKey:model];
	
	//Morph removeCommand to MoveCommand
	if(existingCommand && [existingCommand isKindOfClass:[CKModelObserverRemoveCommand class]]){
		CKModelObserverRemoveCommand* existingRemoveCommand = (CKModelObserverRemoveCommand*)existingCommand;
		[toExecuteList removeObjectForKey:model];
		
		CKModelObserverMoveCommand* moveCommand = [[[CKModelObserverMoveCommand alloc]init]autorelease];
		moveCommand.initialIndex = existingRemoveCommand.index;
		moveCommand.index = index;
		moveCommand.model = model;
		moveCommand.imageView = existingRemoveCommand.imageView;
		moveCommand.modelObserver = self;
		[changeList setObject:moveCommand forKey:model];
		
		// Stops the previous animation
		//TODO
	}
	else if(existingCommand){
		NSAssert(NO,@"This should not happen");
	}
	//Create Insert Command
	else{
		CKModelObserverInsertCommand* insertCommand = [[[CKModelObserverInsertCommand alloc]init]autorelease];
		insertCommand.index = index;
		insertCommand.model = model;
		insertCommand.modelObserver = self;
		[changeList setObject:insertCommand forKey:model];
	}
}

- (void)removeModel:(id)model atIndex:(int)index{
	if(model == nil){
		NSLog(@"CKModelObserver Try to remove a nil model Object. Ignoring this command");
		return;
	}
	
	CKModelObserverCommand* existingCommand = [changeList objectForKey:model];
	
	if(existingCommand && [existingCommand isKindOfClass:[CKModelObserverMoveCommand class]]){
		CKModelObserverMoveCommand* existingMoveCommand = (CKModelObserverMoveCommand*)existingCommand;
		[toExecuteList removeObjectForKey:model];
		
		CKModelObserverRemoveCommand* removeCommand = [[[CKModelObserverRemoveCommand alloc]init]autorelease];
		removeCommand.index = existingMoveCommand.initialIndex;
		removeCommand.model = model;
		removeCommand.modelObserver = self;
		removeCommand.imageView = existingMoveCommand.imageView;
		[changeList setObject:removeCommand forKey:model];
	}
	else if(existingCommand && [existingCommand isKindOfClass:[CKModelObserverRemoveCommand class]]){
		NSAssert(NO,@"???");
		return;
	}
	//Create Remove Command
	else{
		CKModelObserverRemoveCommand* removeCommand = [[[CKModelObserverRemoveCommand alloc]init]autorelease];
		removeCommand.index = index;
		removeCommand.model = model;
		removeCommand.modelObserver = self;
		[changeList setObject:removeCommand forKey:model];
	}
}

- (NSMutableArray*)orderCommands:(NSArray*)baseArray{
	NSMutableArray* values = [NSMutableArray arrayWithArray:baseArray];
	NSMutableArray* sortedValues = [NSMutableArray arrayWithArray:[values sortedArrayUsingComparator: ^(id obj1, id obj2){
		int index1 = [obj1 isKindOfClass:[CKModelObserverMoveCommand class]] ? ((CKModelObserverMoveCommand*)obj1).initialIndex : ((CKModelObserverCommand*)obj1).index;
		int index2 = [obj2 isKindOfClass:[CKModelObserverMoveCommand class]] ? ((CKModelObserverMoveCommand*)obj2).initialIndex : ((CKModelObserverCommand*)obj2).index;
		if (index1 > index2) {
			return (NSComparisonResult)NSOrderedDescending;
		}
		else if (index1 < index2) {
			return (NSComparisonResult)NSOrderedAscending;
		}
		return (NSComparisonResult)NSOrderedSame;
	}]];
	return sortedValues;
}

- (void)execute{
	NSMutableArray* sortedValues = [self orderCommands:[toExecuteList allValues]];
	
	while([sortedValues count] > 0 && state == CKModelObserverStateExecuting){
		CKModelObserverCommand* command = [sortedValues objectAtIndex:0];
		[command updateSubControllers];
		[sortedValues removeObjectAtIndex:0];
		[toExecuteList removeObjectForKey:command.model];
		[changeList removeObjectForKey:command.model];
	}
	
	if(state == CKModelObserverStateExecuting){
		state = CKModelObserverStateWaiting;
		
		if(delegate && [delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
			if([delegate respondsToSelector:@selector(modelObserverDidChange:)]){
				[delegate performSelector:@selector(modelObserverDidChange:) withObject:self];
			}
			else{
				NSAssert(NO,@"delegate do not implement modelObserverDidChange:");
			}
		}
		else{
			NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
		}
	}
}

- (void)removeCommandForModel:(id)model{
	CKModelObserverCommand* command = [self.changeList objectForKey:model];
	if(command == nil){
		NSLog(@"CKModelObserver animation ended on a remove command from changeList");
		return;
	}
	
	[self.toExecuteList setObject:command forKey:model];
	
	if([self.changeList count] == [self.toExecuteList count]
	   && state == CKModelObserverStateAnimating){
		state = CKModelObserverStateExecuting;
		[self execute];
	}
}

- (void)executeNow{
	for(CKModelObserverCommand* command in [changeList allValues]){
		[self.toExecuteList setObject:command forKey:command.model];
		//Make sure we clear anims because anims retains command as a delegate
		if(command.imageView){
			[command.imageView.layer removeAllAnimations];
			[command.imageView removeFromSuperview];
		}
	}
	
	state = CKModelObserverStateExecuting;
	[self execute];
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if(delegate && [delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
		if([delegate respondsToSelector:@selector(modelObserverWillChange:)]){
			[delegate performSelector:@selector(modelObserverWillChange:) withObject:self];
		}
		else{
			NSAssert(NO,@"delegate do not implement modelObserverWillChange:");
		}
	}
	else{
		NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
	}
	
	
	NSIndexSet* indexs = [change objectForKey:NSKeyValueChangeIndexesKey];
	NSArray *oldModels = [change objectForKey: NSKeyValueChangeOldKey];
	NSArray *newModels = [change objectForKey: NSKeyValueChangeNewKey];
	
	NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
	
	NSArray* items = [document objectsForKey:objectsKey];
	
	int count = 0;
	unsigned currentIndex = [indexs firstIndex];
	int lastIndex = -1;
	switch(kind){
			//TODO : adapt remove commands that can be afected by moves ...
			
		case NSKeyValueChangeInsertion:{
			state = CKModelObserverStateObserving;
			while (currentIndex != NSNotFound) {
				if(lastIndex >= 0){
					//move lastIndex +1 to currentIndex -1 offset = +index
					for(int i=lastIndex+1;i<currentIndex;++i){
						[self moveModel:[items objectAtIndex:i] fromIndex:i-count toIndex:i]; 
					}
				}
				
				NSAssert(count < [newModels count],@"Problem with observer change newModels");
				[self insertModel:[newModels objectAtIndex:count] atIndex:currentIndex];
				
				lastIndex = currentIndex;
				currentIndex = [indexs indexGreaterThanIndex: currentIndex];
				++count;
			}
			if(lastIndex >= 0){
				//move lastIndex +1 to end offset = +index
				for(int i=lastIndex+1;i<[items count];++i){
					[self moveModel:[items objectAtIndex:i] fromIndex:i-count toIndex:i]; 
				}
			}
			break;
		}
		case NSKeyValueChangeRemoval:{
			if([items count] <= 0){
				if(delegate && [delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
					if([delegate respondsToSelector:@selector(modelObserverClearAll:)]){
						[delegate performSelector:@selector(modelObserverClearAll:) withObject:self];
					}
					else{
						NSAssert(NO,@"delegate do not implement modelObserverClearAll:");
					}
				}
				else{
					NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
				}
				
				state = CKModelObserverStateWaiting;
				
				if(delegate && [delegate conformsToProtocol:@protocol(CKModelObserverDelegate)]){
					if([delegate respondsToSelector:@selector(modelObserverDidChange:)]){
						[delegate performSelector:@selector(modelObserverDidChange:) withObject:self];
					}
					else{
						NSAssert(NO,@"delegate do not implement modelObserverDidChange:");
					}
				}
				else{
					NSAssert(NO,@"delegate is nil or cot conforms to CKModelObserverDelegate");
				}
				
				return;
			}
			else{
				while (currentIndex != NSNotFound) {
					state = CKModelObserverStateObserving;
					if(lastIndex >= 0){
						//move lastIndex +1 to currentIndex -1 offset = -index
						for(int i=lastIndex+1 - count ;i<currentIndex - count;++i){
							[self moveModel:[items objectAtIndex:i] fromIndex:i + count toIndex:i]; 
						}
					}
					NSAssert(count < [oldModels count],@"Problem with observer change newModels");
					[self removeModel:[oldModels objectAtIndex:count] atIndex:currentIndex];
					lastIndex = currentIndex;
					currentIndex = [indexs indexGreaterThanIndex: currentIndex];
					++count;
				}
				if(lastIndex >= 0){
					//move lastIndex +1 to end offset = -index
					for(int i=lastIndex+1 - count;i<[items count];++i){
						[self moveModel:[items objectAtIndex:i] fromIndex:i + count toIndex:i]; 
					}
				}
			}
			break;
		}
	}
	
	state = CKModelObserverStateAnimating;
	NSArray* sortedValues = [self orderCommands:[changeList allValues]];
	for(CKModelObserverCommand* command in sortedValues){
		[command lanchAnimation];
	}
}

@end


@implementation CKModelObserver (CKFeedSourceHelper)

- (void)initWithFeedSource:(CKFeedSource *)source delegate:(id)thedelegate{
	[self initWithDocument:source.document key:source.objectsKey delegate:thedelegate];
}

@end
