//
//  CKCollectionController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKCollectionController.h"
#import "CKDocument.h"
#import <UIKit/UITableView.h>
#import "CKNSObject+Invocation.h"
#import "CKVersion.h"

@implementation CKCollectionController
@synthesize collection = _collection;
@synthesize delegate = _delegate;
@synthesize appendCollectionCellControllerAsFooterCell;
@synthesize maximumNumberOfObjectsToDisplay;
@synthesize animateInsertionsOnReload;

- (void)dealloc{
	if(_collection){
		//[_document releaseObjectsForKey:_key];
		if(observing){
			[_collection removeObserver:self];
		}
	}
	
	[_collection release];
	_collection = nil;
	_delegate = nil;
	
	[super dealloc];
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
        
        appendCollectionCellControllerAsFooterCell = NO;
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

- (void)setDelegate:(id)theDelegate{
	_delegate = theDelegate;
	if(theDelegate){
		[self start];
	}
	else{
		[self stop];
	}
}


- (void)fetchRange:(NSRange)range forSection:(int)section{
	NSAssert(section == 0,@"Invalid section");
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

- (NSInteger)numberOfSections{
	return 1;
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	NSInteger count = (maximumNumberOfObjectsToDisplay > 0) ? MIN(maximumNumberOfObjectsToDisplay,[_collection count]) : [_collection count];
	if(appendCollectionCellControllerAsFooterCell && _collection.feedSource){
		return count + 1;
	}
	else {
		return count;
	}

	return 0;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath{
	if(indexPath.length != 2)
		return nil;
	
	NSInteger count = (maximumNumberOfObjectsToDisplay > 0) ? MIN(maximumNumberOfObjectsToDisplay,[_collection count]) : [_collection count];
	if(indexPath.row < count){
		NSInteger index = indexPath.row;
		return [_collection objectAtIndex:index];
	}
	else if(appendCollectionCellControllerAsFooterCell && _collection.feedSource){
		return _collection;
	}

	return nil;
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.length != 2)
		return;
	
	[_collection removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row]];
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

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(locked){
            changedWhileLocked = YES;
            return;
        }
		
        NSIndexSet* indexs = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSArray *oldModels = [change objectForKey: NSKeyValueChangeOldKey];
        NSArray *newModels = [change objectForKey: NSKeyValueChangeNewKey];
        
        NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
        
        if(!animateInsertionsOnReload && kind == NSKeyValueChangeInsertion && ([newModels count] == [_collection count])){
            if([_delegate respondsToSelector:@selector(objectControllerReloadData:)]){
                [_delegate objectControllerReloadData:self];
                return;
            }
        }
        
        //if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
        if([_delegate respondsToSelector:@selector(objectControllerDidBeginUpdating:)]){
            [_delegate objectControllerDidBeginUpdating:self];
        }
        //}
        
        int count = 0;
        unsigned currentIndex = [indexs firstIndex];
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
                    
                    if([_delegate respondsToSelector:@selector(objectController:insertObjects:atIndexPaths:)]){
                        [_delegate objectController:self insertObjects:limitedObjects atIndexPaths:limitedIndexPaths];
                    }
                    break;
                }
                
                if([_delegate respondsToSelector:@selector(objectController:insertObjects:atIndexPaths:)]){
                    [_delegate objectController:self insertObjects:newModels atIndexPaths:indexPaths];
                }
                break;
            }
            case NSKeyValueChangeRemoval:{
                if([_delegate respondsToSelector:@selector(objectController:removeObjects:atIndexPaths:)]){
                    [_delegate objectController:self removeObjects:oldModels atIndexPaths:indexPaths];
                }
                break;
            }
        }
        
        //if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
        if([_delegate respondsToSelector:@selector(objectControllerDidEndUpdating:)]){
            [_delegate objectControllerDidEndUpdating:self];
        }
        //}
    });
}

- (void)lock{
	locked = YES;
	[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
}

- (void)unlock{
	locked = NO;
	if(changedWhileLocked){
		if([_delegate respondsToSelector:@selector(objectControllerReloadData:)]){
			[_delegate objectControllerReloadData:self];
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
