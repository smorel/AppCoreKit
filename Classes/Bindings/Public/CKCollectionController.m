//
//  CKCollectionController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollectionController.h"
#import "NSObject+Invocation.h"
#import "CKVersion.h"
#import "CKDebug.h"
#import "CKWeakRef.h"

@interface CKCollectionController()
@property (nonatomic, retain,readwrite) CKCollection* collection;
@property (nonatomic, retain,readwrite) CKWeakRef* delegateRef;
@property (nonatomic, assign) BOOL animateInsertionsOnReload;
@end

@implementation CKCollectionController{
	CKCollection* _collection;
	BOOL observing;
	BOOL animateInsertionsOnReload;
	NSInteger maximumNumberOfObjectsToDisplay;
	BOOL locked;
	BOOL changedWhileLocked;
}

@synthesize collection = _collection;
@synthesize delegate;
@synthesize maximumNumberOfObjectsToDisplay;
@synthesize animateInsertionsOnReload;
@synthesize delegateRef = _delegateRef;

- (void)dealloc{
	if(_collection){
		//[_document releaseObjectsForKey:_key];
		if(observing){
			[_collection removeObserver:self];
		}
	}
	
	[_collection release];
	_collection = nil;
    [_delegateRef release];
    _delegateRef = nil;
	
	[super dealloc];
}

- (void)setDelegate:(id)theDelegate{
    __block CKCollectionController* bself = self;
    self.delegateRef = theDelegate ? [CKWeakRef weakRefWithObject:theDelegate block:^(CKWeakRef *weakRef) {
		[bself stop];
    }] : nil;
    
    if(theDelegate){
		[self start];
	}
	else{
		[self stop];
	}
}

- (id)delegate{
    return _delegateRef ? self.delegateRef.object : nil;
}

+ (CKCollectionController*) controllerWithCollection:(CKCollection*)collection{
	CKCollectionController* controller = [[[CKCollectionController alloc]initWithCollection:collection]autorelease];
	return controller;
}

- (id)initWithCollection:(CKCollection*)theCollection{
    if (self = [super init]) {
        self.maximumNumberOfObjectsToDisplay = 0;
        self.collection = theCollection;
        
        if(theCollection){
            //[_document retainObjectsForKey:_key];
        }
        observing = NO;
        
        animateInsertionsOnReload = ([CKOSVersion() floatValue] < 3.2) ? NO : YES;
        locked = NO;
        changedWhileLocked = NO;
    }
	
	return self;
}

- (void)start{
	if(_collection && !observing){
		observing = YES;
		[_collection addObserver:self];
	}
}

- (void)stop{
	if(_collection && observing){
		observing = NO;
		[_collection removeObserver:self];
		
		CKFeedSource* feedSource = _collection.feedSource;
		if(feedSource){
			[feedSource cancelFetch];
		}
	}
}

- (void)fetchRange:(NSRange)range forSection:(NSInteger)section{
	CKAssert(section == 0,@"Invalid section");
	/*if(_collection && _collection.feedSource){
		range.location--;
	}*/
    
    if(self.maximumNumberOfObjectsToDisplay > 0 && [_collection count] > self.maximumNumberOfObjectsToDisplay)
        return;
			
	//Adjust range using limit
	range.location = (maximumNumberOfObjectsToDisplay > 0) ? MIN(maximumNumberOfObjectsToDisplay,range.location) : range.location;
	range.length = (maximumNumberOfObjectsToDisplay > 0) ? MIN(maximumNumberOfObjectsToDisplay - range.location,range.length - range.location) : range.length;
	[_collection fetchRange:range];
}

- (NSUInteger)numberOfSections{
	return 1;
}

- (NSUInteger)numberOfObjectsForSection:(NSInteger)section{
	NSInteger count = (maximumNumberOfObjectsToDisplay > 0) ? MIN(maximumNumberOfObjectsToDisplay,[_collection count]) : [_collection count];
	
    return count;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath{
	if(indexPath.length != 2)
		return nil;
	
	NSInteger count = (maximumNumberOfObjectsToDisplay > 0) ? MIN(maximumNumberOfObjectsToDisplay,[_collection count]) : [_collection count];
	if(indexPath.row < count){
		NSInteger index = indexPath.row;
		return [_collection objectAtIndex:index];
	}
	return nil;
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.length != 2)
		return;
	
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:indexPath.row];
	[_collection removeObjectsAtIndexes:indexSet];
}

- (NSIndexPath*)targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
	//TODO : if moving on dataSource, propose the last document item instead
	return proposedDestinationIndexPath;
}

- (void)moveObjectFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)indexPath2{
	if(indexPath.length != 2 || indexPath2.length != 2)
		return;
	
	if(_collection){
		[_collection removeObserver:self];
	}
	
	id object = [_collection objectAtIndex:indexPath.row];
	[_collection removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:  indexPath.row]];
	[_collection insertObjects:[NSArray arrayWithObject:object] atIndexes:[NSIndexSet indexSetWithIndex:indexPath2.row]];

	if(_collection){
		[_collection addObserver:self];
	}
}

- (NSIndexPath*)indexPathForDocumentObjectAtIndex:(NSInteger)index{
	return [NSIndexPath indexPathForRow:index inSection:0];
}

- (void)update:(NSDictionary*)dico{
    //dispatch_async(dispatch_get_main_queue(), ^{
    if(locked){
        changedWhileLocked = YES;
        return;
    }
    
    if(!self.delegate)
        return;
    
    NSDictionary* change = [dico objectForKey:@"change"];
    
    NSIndexSet* indexs = [change objectForKey:NSKeyValueChangeIndexesKey];
    NSArray *oldModels = [change objectForKey: NSKeyValueChangeOldKey];
    NSArray *newModels = [change objectForKey: NSKeyValueChangeNewKey];
    
    NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
    
    if(!animateInsertionsOnReload && kind == NSKeyValueChangeInsertion && ([newModels count] == [_collection count])){
        if([self.delegate respondsToSelector:@selector(objectControllerReloadData:)]){
            [self.delegate objectControllerReloadData:self];
            return;
        }
    }
    
    //if([self.delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
    if([self.delegate respondsToSelector:@selector(objectControllerDidBeginUpdating:)]){
        id d = [self delegate];
        [d retain];//This is a Hack because it happend sometimes that here the delegate is OK, but when calling objectControllerDidBeginUpdating, it has been deallocated.
                   //This is totally weirdo ...
        [d objectControllerDidBeginUpdating:self];
        [d release];
    }
    //}
    
    NSInteger count = 0;
    NSUInteger currentIndex = [indexs firstIndex];
    NSMutableArray* indexPaths = [NSMutableArray array];
    while (currentIndex != NSNotFound) {
        //Do not notify add if currentIndex > limit
        [indexPaths addObject:[self indexPathForDocumentObjectAtIndex:currentIndex]];
        currentIndex = [indexs indexGreaterThanIndex: currentIndex];
        ++count;
    }
    
    switch(kind){
        case NSKeyValueChangeInsertion:{
            if(maximumNumberOfObjectsToDisplay > 0) {
                NSMutableArray* limitedIndexPaths = [NSMutableArray array];
                NSMutableArray* limitedObjects = [NSMutableArray array];
                for(int i=0;i<[indexPaths count];++i){
                    NSIndexPath* indexpath = [indexPaths objectAtIndex:i];
                    if(indexpath.row < maximumNumberOfObjectsToDisplay){
                        [limitedIndexPaths addObject:indexpath];
                        id object = [newModels objectAtIndex:i];
                        [limitedObjects addObject:object];
                    }
                }
                
                if([self.delegate respondsToSelector:@selector(objectController:insertObjects:atIndexPaths:)]){
                    [self.delegate objectController:self insertObjects:limitedObjects atIndexPaths:limitedIndexPaths];
                }
                break;
            }
            
            if([self.delegate respondsToSelector:@selector(objectController:insertObjects:atIndexPaths:)]){
                [self.delegate objectController:self insertObjects:newModels atIndexPaths:indexPaths];
            }
            break;
        }
        case NSKeyValueChangeRemoval:{
            if([self.delegate respondsToSelector:@selector(objectController:removeObjects:atIndexPaths:)]){
                [self.delegate objectController:self removeObjects:oldModels atIndexPaths:indexPaths];
            }
            break;
        }
    }
    
    //if([self.delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
    if([self.delegate respondsToSelector:@selector(objectControllerDidEndUpdating:)]){
        [self.delegate objectControllerDidEndUpdating:self];
    }
    //}
    //});
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    [self performSelector:@selector(update:) onThread:[NSThread mainThread] withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        theKeyPath,@"keyPath",
                                                                                        object,@"object",
                                                                                        change,@"change",
                                                                                        nil]
            waitUntilDone:YES];
}

- (void)lock{
	locked = YES;
	[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
}

- (void)unlock{
	locked = NO;
	if(changedWhileLocked){
		if([self.delegate respondsToSelector:@selector(objectControllerReloadData:)]){
			[self.delegate objectControllerReloadData:self];
		}
		changedWhileLocked = NO;
	}
}


- (NSString*)headerTitleForSection:(NSInteger)section{
    return nil;
}

- (UIView*)headerViewForSection:(NSInteger)section{
    return nil;
}

- (NSString*)footerTitleForSection:(NSInteger)section{
    return nil;
}

- (UIView*)footerViewForSection:(NSInteger)section{
    return nil;
}

@end
