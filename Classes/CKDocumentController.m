//
//  CKFeedController.m
//  FeedView
//
//  Created by Sebastien Morel on 11-03-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKDocumentController.h"
#import <CloudKit/CKDocument.h>
#import <UIKit/UITableView.h>
#import "CKVersion.h"

@implementation CKDocumentController
@synthesize collection = _collection;
@synthesize delegate = _delegate;
@synthesize displayFeedSourceCell;
@synthesize numberOfFeedObjectsLimit;
@synthesize animateFirstInsertion;

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

- (id)initWithCollection:(CKDocumentCollection*)theCollection{
	[super init];

	self.numberOfFeedObjectsLimit = 0;
	self.collection = theCollection;
	
	if(theCollection){
		//[_document retainObjectsForKey:_key];
	}
	observing = NO;
	
	displayFeedSourceCell = YES;
	animateFirstInsertion = ([CKOSVersion() floatValue] < 3.2) ? NO : YES;
	
	return self;
}


- (void)viewWillAppear{
	if(_collection && !observing){
		observing = YES;
		[_collection addObserver:self];
		if([_collection count] <= 0){
			CKFeedSource* feedSource = _collection.feedSource;
			if(feedSource){
				NSInteger count = [_collection count];
				NSInteger requested = (numberOfFeedObjectsLimit > 0) ? MIN(numberOfFeedObjectsLimit,10) : 10;
				if(requested > count){
					[feedSource fetchRange:NSMakeRange(count, count - requested)];
				}
			}
		}
	}
}

- (void)viewWillDisappear{
	if(_collection && observing){
		observing = NO;
		[_collection removeObserver:self];
		
		CKFeedSource* feedSource = _collection.feedSource;
		if(feedSource){
			[feedSource cancelFetch];
		}
	}
}

- (void)fetchRange:(NSRange)range forSection:(int)section{
	NSAssert(section == 0,@"Invalid section");
	if(_collection && _collection.feedSource){
		range.location--;
	}
			
	//Adjust range using limit
	range.location = (numberOfFeedObjectsLimit > 0) ? MIN(numberOfFeedObjectsLimit,range.location) : range.location;
	range.length = (numberOfFeedObjectsLimit > 0) ? MIN(numberOfFeedObjectsLimit - range.location,range.length - range.location) : range.length;
	[_collection fetchRange:range];
}

- (NSInteger)numberOfSections{
	return 1;
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	NSInteger count = (numberOfFeedObjectsLimit > 0) ? MIN(numberOfFeedObjectsLimit,[_collection count]) : [_collection count];
	if(_collection.feedSource){
		return count + 1;
	}
	else {
		return count;
	}

	return 0;
}

- (NSString*)headerTitleForSection:(NSInteger)section{
	return nil;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath{
	if(indexPath.length != 2)
		return nil;
	
	NSInteger count = (numberOfFeedObjectsLimit > 0) ? MIN(numberOfFeedObjectsLimit,[_collection count]) : [_collection count];
	if(indexPath.row < count){
		NSInteger index = indexPath.row;
		return [_collection objectAtIndex:index];
	}
	else if(displayFeedSourceCell && _collection.feedSource){
		return _collection;
	}

	return nil;
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.length != 2)
		return;
	
	[_collection removeObjectsInArray:[NSArray arrayWithObject:[self objectAtIndexPath:indexPath]]];
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
	
	id object = [self objectAtIndexPath:indexPath];
	[_collection removeObjectsInArray:[NSArray arrayWithObject:object]];
	[_collection insertObjects:[NSArray arrayWithObject:object] atIndexes:[NSIndexSet indexSetWithIndex:  indexPath2.row]];

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
		
	NSIndexSet* indexs = [change objectForKey:NSKeyValueChangeIndexesKey];
	NSArray *oldModels = [change objectForKey: NSKeyValueChangeOldKey];
	NSArray *newModels = [change objectForKey: NSKeyValueChangeNewKey];
	
	NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];
	
	if(!animateFirstInsertion && kind == NSKeyValueChangeInsertion && ([newModels count] == [_collection count])){
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
	switch(kind){
		case NSKeyValueChangeInsertion:{
			while (currentIndex != NSNotFound) {
				NSAssert(count < [newModels count],@"Problem with observer change newModels");
				
				//Do not notify add if currentIndex > limit
				if(numberOfFeedObjectsLimit > 0 && currentIndex >= numberOfFeedObjectsLimit){/*Do nothing*/}
				else{
					//if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
					if([_delegate respondsToSelector:@selector(objectController:insertObject:atIndexPath:)]){
						[_delegate objectController:self insertObject:[newModels objectAtIndex:count] atIndexPath:[self indexPathForDocumentObjectAtIndex:currentIndex]];
					}
					//}
				}
				currentIndex = [indexs indexGreaterThanIndex: currentIndex];
				++count;
			}
			break;
		}
		case NSKeyValueChangeRemoval:{
			while (currentIndex != NSNotFound) {
				NSAssert(count < [oldModels count],@"Problem with observer change newModels");
				//if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
					if([_delegate respondsToSelector:@selector(objectController:removeObject:atIndexPath:)]){
						[_delegate objectController:self removeObject:[oldModels objectAtIndex:count] atIndexPath:[self indexPathForDocumentObjectAtIndex:currentIndex]];
					}
				//}
				currentIndex = [indexs indexGreaterThanIndex: currentIndex];
				++count;
			}
			break;
		}
	}	
	
	//if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
		if([_delegate respondsToSelector:@selector(objectControllerDidEndUpdating:)]){
			[_delegate objectControllerDidEndUpdating:self];
		}
	//}
}


@end
