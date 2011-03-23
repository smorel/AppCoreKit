//
//  CKFeedViewControllerFactory.m
//  FeedView
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectViewControllerFactory.h"
#import "CKObjectController.h"
#import "CKFeedSourceViewCellController.h"
#import "CKFeedSource.h"


@implementation CKObjectViewControllerFactory
@synthesize mappings = _mappings;
@synthesize objectController = _objectController;
@synthesize styles = _styles;

- (void)dealloc{
	[_mappings release];
	_mappings = nil;
	[_styles release];
	_styles = nil;
	_objectController = nil;
	[super dealloc];
}

+ (CKObjectViewControllerFactory*)factoryWithMappings:(NSDictionary*)mappings withStyles:(NSDictionary*)styles{
	CKObjectViewControllerFactory* factory = [[[CKObjectViewControllerFactory alloc]init]autorelease];
	factory.mappings = mappings;
	factory.styles = styles;
	return factory;
}

- (Class)controllerClassForIndexPath:(NSIndexPath*)indexPath{
	[_mappings setObject:[CKFeedSourceViewCellController class] forKey:[CKFeedSource class]];
	if(_objectController && [_objectController conformsToProtocol:@protocol(CKObjectController)]){
		id object = [_objectController objectAtIndexPath:indexPath];
		for(Class c in [_mappings allKeys]){
			if([object isKindOfClass:c]){
				return [_mappings objectForKey:c];
			}
		}
	}
	return nil;
}

- (id)styleForIndexPath:(NSIndexPath*)indexPath{
	Class controllerClass = [self controllerClassForIndexPath:indexPath];
	return _styles ? [_styles objectForKey:controllerClass] : nil;
}

- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath{
	//Can be implemented by overloading CKFeedViewControllerFactory
}

@end
