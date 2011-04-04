//
//  CKPropertiesTableViewController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKPropertiesTableViewController.h"
#import "CKObjectController.h"
#import "CKObjectProperty.h"
#import <objc/runtime.h>
#import "CKNSNumberPropertyCellController.h"
#import "CKNSStringPropertyCellController.h"

@interface CKObjectPropertiesController : NSObject<CKObjectController> {
	id _object;
	id _delegate;
}
@property (nonatomic, retain) id object;
@property (nonatomic, assign) id delegate;
- (id)initWithObject:(id)object;
@end

@implementation CKObjectPropertiesController
@synthesize object = _object;
@synthesize delegate = _delegate;

- (void)dealloc{
	[_object release];
	_object = nil;
	[super dealloc];
}

- (id)initWithObject:(id)theobject{
	[self init];
	self.object = theobject;
	return self;
}

- (NSInteger)numberOfSections{
	return 1;
}

- (NSInteger)numberOfObjectsForSection:(NSInteger)section{
	NSArray* properties = [_object allPropertyDescriptors];
	return [properties count];
}

- (NSString*)headerTitleForSection:(NSInteger)section{
	return [NSString stringWithUTF8String:class_getName([_object class])];
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath{
	NSArray* properties = [_object allPropertyDescriptors];
	CKClassPropertyDescriptor* property = [properties objectAtIndex:indexPath.row];
	CKObjectProperty* retValue = [[[CKObjectProperty alloc]init]autorelease];
	retValue.object = _object;
	retValue.keyPath = property.name;
	return retValue;
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	//Not Allowed yet as we do not deals with arrays
}

- (NSIndexPath*)targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
	//Not Allowed yet as we do not deals with arrays
	return proposedDestinationIndexPath;
}

- (void)moveObjectFromIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)indexPath2{
	//Not Allowed yet as we do not deals with arrays
}

- (void)viewWillAppear{
	//Do nothing
}

- (void)viewWillDisappear{
	//Do nothing
}

- (void)fetchRange:(NSRange)range forSection:(int)section{
	//Do nothing
}

@end

@interface CKObjectPropertiesControllerFactory : CKObjectViewControllerFactory {
}
@end

@implementation CKObjectPropertiesControllerFactory
- (Class)controllerClassForIndexPath:(NSIndexPath*)indexPath{
	if(_objectController && [_objectController conformsToProtocol:@protocol(CKObjectController)]){
		CKObjectProperty* objectKeyValue = [_objectController objectAtIndexPath:indexPath];
		id object = [objectKeyValue.object valueForKeyPath:objectKeyValue.keyPath];
		for(Class c in [_mappings allKeys]){
			if([object isKindOfClass:c]){
				return [_mappings objectForKey:c];
			}
		}
	}
	return nil;
}

@end




@implementation CKPropertiesTableViewController

- (id)initWithObject:(id)object withStyles:(NSDictionary*)styles{
	[self init];
	NSMutableDictionary* mappings = [NSMutableDictionary dictionary];
	[mappings setObject:[CKNSNumberPropertyCellController class] forKey:[NSNumber class]];
	[mappings setObject:[CKNSStringPropertyCellController class] forKey:[NSString class]];
	
	self.controllerFactory = [CKObjectViewControllerFactory factoryWithMappings:mappings withStyles:styles withFactoryClass:[CKObjectPropertiesControllerFactory class]];
	self.objectController = [[[CKObjectPropertiesController alloc]initWithObject:object]autorelease];
	return self;
}

@end
