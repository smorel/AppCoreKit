//
//  CKFeedViewControllerFactory.m
//  FeedView
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectViewControllerFactory.h"
#import "CKObjectController.h"
#import "CKDocumentCollectionCellController.h"
#import "CKDocumentCollection.h"
#import <objc/runtime.h>


@implementation CKObjectViewControllerFactory
@synthesize mappings = _mappings;
@synthesize objectController = _objectController;

- (void)dealloc{
	[_mappings release];
	_mappings = nil;
	_objectController = nil;
	[super dealloc];
}

+ (CKObjectViewControllerFactory*)factoryWithMappings:(NSDictionary*)mappings {
	return [CKObjectViewControllerFactory factoryWithMappings:mappings withFactoryClass:[CKObjectViewControllerFactory class]];
}

+ (id)factoryWithMappings:(NSDictionary*)mappings withFactoryClass:(Class)type{
	CKObjectViewControllerFactory* factory = (CKObjectViewControllerFactory*)[[[type alloc]init]autorelease];
	factory.mappings = mappings;
	if(factory.mappings){
		[factory.mappings setObject:[CKDocumentCollectionViewCellController class] forKey:[CKDocumentCollection class]];
	}
	return factory;
}

- (void)setMappings:(id)theMappings{
	[_mappings release];
	_mappings = [theMappings retain];
	if(_mappings){
		[_mappings setObject:[CKDocumentCollectionViewCellController class] forKey:[CKDocumentCollection class]];
	}
}

- (Class)controllerClassForIndexPath:(NSIndexPath*)indexPath{
	//if(_objectController && [_objectController conformsToProtocol:@protocol(CKObjectController)]){
	id object = [_objectController objectAtIndexPath:indexPath];
	Class returnClass = [_mappings objectForKey:[object class]];
	if(returnClass == nil){
		Class objectClass = [object class];
		objectClass = class_getSuperclass(objectClass);
		while(objectClass != nil){
			returnClass = [_mappings objectForKey:objectClass];
			if(returnClass != nil){
				[_mappings setObject:returnClass forKey:objectClass];
				return returnClass;
			}
			objectClass = class_getSuperclass(objectClass);
		}
	}
	return returnClass;
}

- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath{
	//Can be implemented by overloading CKFeedViewControllerFactory
}

@end
