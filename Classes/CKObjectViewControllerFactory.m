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
#import "CKStyleManager.h"


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
	return [CKObjectViewControllerFactory factoryWithMappings:mappings withStyles:styles withFactoryClass:[CKObjectViewControllerFactory class]];
}

+ (id)factoryWithMappings:(NSDictionary*)mappings withStyles:(NSDictionary*)styles withFactoryClass:(Class)type{
	CKObjectViewControllerFactory* factory = (CKObjectViewControllerFactory*)[[[type alloc]init]autorelease];
	factory.mappings = mappings;
	if(factory.mappings){
		[factory.mappings setObject:[CKDocumentCollectionViewCellController class] forKey:[CKDocumentCollection class]];
	}
	factory.styles = styles;
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
	   for(Class c in [_mappings allKeys]){
		   if([object isKindOfClass:c]){
			   returnClass = [_mappings objectForKey:c];
			   [_mappings setObject:returnClass forKey:[object class]];
			   break;
		   }
	   }
	}
	return returnClass;
}

- (id)styleForIndexPath:(NSIndexPath*)indexPath{
	Class controllerClass = [self controllerClassForIndexPath:indexPath];
	NSString* styleIdentifier = _styles ? [_styles objectForKey:controllerClass] : nil;
	return (styleIdentifier != nil) ? [CKStyleManager styleForKey:styleIdentifier] : nil;
}

- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath{
	//Can be implemented by overloading CKFeedViewControllerFactory
}

@end
