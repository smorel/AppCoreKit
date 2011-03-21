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

@implementation CKDocumentController
@synthesize document = _document;
@synthesize key = _key;
@synthesize delegate = _delegate;

- (void)dealloc{
	if(_document){
		[_document releaseObjectsForKey:_key];
		[_document removeObserver:self forKey:_key];
	}
	
	_document = nil;
	_delegate = nil;
	[_key release];
	_key = nil;
	[super dealloc];
}

- (id)initWithDocument:(id)theDocument key:(NSString*)theKey{
	[super init];
	
	if(_document){
		[_document releaseObjectsForKey:_key];
		[_document removeObserver:self forKey:_key];
	}
	
	self.document = theDocument;
	self.key = theKey;
	
	if(_document){
		[_document addObserver:self forKey:_key];
		[_document retainObjectsForKey:_key];
	}
	
	return self;
}


- (void)fetchRange:(NSRange)range forSection:(int)section{
	NSAssert(section == 0,@"Invalid section");
	if(_document && [_document conformsToProtocol:@protocol(CKDocument)]){
		if([_document respondsToSelector:@selector(fetchRange:forKey:)]){
			[_document fetchRange:range forKey:_key];
		}
	}
}

- (NSInteger)numberOfSections{
	return 1;
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	if(_document && [_document conformsToProtocol:@protocol(CKDocument)]){
		if([_document respondsToSelector:@selector(objectsForKey:)]){
			NSArray* objects = [_document objectsForKey:_key];
			return [objects count];
		}
	}
	return 0;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath{
	if(indexPath.length != 2)
		return nil;
	
	if(_document && [_document conformsToProtocol:@protocol(CKDocument)]){
		if([_document respondsToSelector:@selector(objectsForKey:)]){
			NSArray* objects = [_document objectsForKey:_key];
			NSInteger index = indexPath.row;
			return [objects objectAtIndex:index];
		}
	}
	return nil;
}

- (NSIndexPath *)indexPathForObject:(id)object{
	if(_document && [_document conformsToProtocol:@protocol(CKDocument)]){
		if([_document respondsToSelector:@selector(objectsForKey:)]){
			NSArray* objects = [_document objectsForKey:_key];
			return [NSIndexPath indexPathForRow:[objects indexOfObject:object] inSection:0];
		}
	}
	return [NSIndexPath indexPathForRow:0 inSection:-1];
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.length != 2)
		return;
	
	if(_document && [_document conformsToProtocol:@protocol(CKDocument)]){
		if([_document respondsToSelector:@selector(removeObjects:forKey:)]){
			[_document removeObjects:[NSArray arrayWithObject:[self objectAtIndexPath:indexPath]] forKey:_key];
		}
	}
}

- (NSIndexPath*)targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
	return proposedDestinationIndexPath;
}

- (void)moveObjectFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)indexPath2{
	if(indexPath.length != 2 || indexPath2.length != 2)
		return;
	
	if(_document){
		[_document removeObserver:self forKey:_key];
	}
	
	if(_document && [_document conformsToProtocol:@protocol(CKDocument)]){
		if([_document respondsToSelector:@selector(removeObjects:forKey:)]){
			id object = [self objectAtIndexPath:indexPath];
			[_document removeObjects:[NSArray arrayWithObject:object] forKey:_key];
			[_document addObjects:[NSArray arrayWithObject:object] atIndex:indexPath2.row forKey:_key];
		}
	}
	if(_document){
		[_document addObserver:self forKey:_key];
	}
}


- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
		if([_delegate respondsToSelector:@selector(objectControllerDidBeginUpdating:)]){
			[_delegate objectControllerDidBeginUpdating:self];
		}
	}
	
	NSIndexSet* indexs = [change objectForKey:NSKeyValueChangeIndexesKey];
	NSArray *oldModels = [change objectForKey: NSKeyValueChangeOldKey];
	NSArray *newModels = [change objectForKey: NSKeyValueChangeNewKey];
	
	NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntValue];

	int count = 0;
	unsigned currentIndex = [indexs firstIndex];
	switch(kind){
		case NSKeyValueChangeInsertion:{
			while (currentIndex != NSNotFound) {
				NSAssert(count < [newModels count],@"Problem with observer change newModels");
				if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
					if([_delegate respondsToSelector:@selector(objectController:insertObject:atIndexPath:)]){
						[_delegate objectController:self insertObject:[newModels objectAtIndex:count] atIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
					}
				}
				currentIndex = [indexs indexGreaterThanIndex: currentIndex];
				++count;
			}
			break;
		}
		case NSKeyValueChangeRemoval:{
			while (currentIndex != NSNotFound) {
				NSAssert(count < [oldModels count],@"Problem with observer change newModels");
				if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
					if([_delegate respondsToSelector:@selector(objectController:removeObject:atIndexPath:)]){
						[_delegate objectController:self removeObject:[oldModels objectAtIndex:count] atIndexPath:[NSIndexPath indexPathForRow:currentIndex inSection:0]];
					}
				}
				currentIndex = [indexs indexGreaterThanIndex: currentIndex];
				++count;
			}
			break;
		}
	}	
	
	if([_delegate conformsToProtocol:@protocol(CKObjectControllerDelegate)]){
		if([_delegate respondsToSelector:@selector(objectControllerDidEndUpdating:)]){
			[_delegate objectControllerDidEndUpdating:self];
		}
	}
}


@end
