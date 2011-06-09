//
//  CKObjectKeyValue.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectProperty.h"
#import "CKNSValueTransformer+Additions.h"


@implementation CKObjectProperty
@synthesize object,keyPath;

- (void)dealloc{
	[object release];
	[keyPath release];
	[super dealloc];
}

+ (CKObjectProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath{
	CKObjectProperty* p = [[[CKObjectProperty alloc]initWithObject:object keyPath:keyPath]autorelease];
	return p;
}

- (id)initWithObject:(id)theobject keyPath:(NSString*)thekeyPath{
	[super init];
	self.object = theobject;
	self.keyPath = thekeyPath;
	return self;
}

+ (CKObjectProperty*)propertyWithObject:(id)object{
	CKObjectProperty* p = [[[CKObjectProperty alloc]initWithObject:object]autorelease];
	return p;
}

- (id)initWithObject:(id)theobject{
	[super init];
	self.object = theobject;
	return self;
}

- (CKClassPropertyDescriptor*)descriptor{
	if(keyPath == nil)
		return nil;
	
	id subObject = object;
	
	NSArray * ar = [keyPath componentsSeparatedByString:@"."];
	for(int i=0;i<[ar count]-1;++i){
		NSString* path = [ar objectAtIndex:i];
		subObject = [subObject valueForKey:path];
	}
	if(subObject == nil){
		NSLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
		return nil;
	}
	return [NSObject propertyDescriptor:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
	//return [NSObject propertyDescriptor:[object class] forKeyPath:keyPath];
}

- (id)value{
	return (keyPath != nil) ? [object valueForKeyPath:keyPath] : object;
}

- (void)setValue:(id)value{
	if(keyPath != nil && [[self value] isEqual:value] == NO){
		[object setValue:value forKeyPath:keyPath];
	}
	else if(keyPath == nil){
		[object copy:value];
	}
}

- (CKDocumentCollection*)editorCollectionWithFilter:(NSString*)filter{
	if(keyPath != nil){
		id subObject = object;
		
		NSArray * ar = [keyPath componentsSeparatedByString:@"."];
		for(int i=0;i<[ar count]-1;++i){
			NSString* path = [ar objectAtIndex:i];
			subObject = [subObject valueForKey:path];
		}
		
		if(subObject == nil){
			NSLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		CKClassPropertyDescriptor* descriptor = [NSObject propertyDescriptor:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
		SEL selector = [NSObject propertyeditorCollectionSelectorForProperty:descriptor.name];
		if([subObject respondsToSelector:selector]){
			CKDocumentCollection* collection = [subObject performSelector:selector withObject:filter];
			return collection;
		}
		else{
			Class type = descriptor.type;
			if([type respondsToSelector:@selector(editorCollectionWithFilter:)]){
				CKDocumentCollection* collection = [type performSelector:@selector(editorCollectionWithFilter:) withObject:filter];
				return collection;
			}
		}
	}
	else{
		Class type = [object class];
		if([type respondsToSelector:@selector(editorCollectionWithFilter:)]){
			CKDocumentCollection* collection = [type performSelector:@selector(editorCollectionWithFilter:) withObject:filter];
			return collection;
		}
	}
	return nil;
}


- (CKDocumentCollection*)editorCollectionForNewlyCreated{
	if(keyPath != nil){
		id subObject = object;
		
		NSArray * ar = [keyPath componentsSeparatedByString:@"."];
		for(int i=0;i<[ar count]-1;++i){
			NSString* path = [ar objectAtIndex:i];
			subObject = [subObject valueForKey:path];
		}
		
		if(subObject == nil){
			NSLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		CKClassPropertyDescriptor* descriptor = [NSObject propertyDescriptor:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
		SEL selector = [NSObject propertyeditorCollectionForNewlyCreatedSelectorForProperty:descriptor.name];
		if([subObject respondsToSelector:selector]){
			CKDocumentCollection* collection = [subObject performSelector:selector];
			return collection;
		}
		else{
			Class type = descriptor.type;
			if([type respondsToSelector:@selector(editorCollectionForNewlyCreated)]){
				CKDocumentCollection* collection = [type performSelector:@selector(editorCollectionForNewlyCreated)];
				return collection;
			}
		}
	}
	else{
		Class type = [object class];
		if([type respondsToSelector:@selector(editorCollectionForNewlyCreated)]){
			CKDocumentCollection* collection = [type performSelector:@selector(editorCollectionForNewlyCreated)];
			return collection;
		}
	}
	return nil;
}


- (CKDocumentCollection*)editorCollectionAtLocation:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius{
	NSValue* valueCoordinate = [NSValue value:&coordinate withObjCType:@encode(CLLocationCoordinate2D)];
	if(keyPath != nil){
		id subObject = object;
		
		NSArray * ar = [keyPath componentsSeparatedByString:@"."];
		for(int i=0;i<[ar count]-1;++i){
			NSString* path = [ar objectAtIndex:i];
			subObject = [subObject valueForKey:path];
		}
		
		if(subObject == nil){
			NSLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		CKClassPropertyDescriptor* descriptor = [NSObject propertyDescriptor:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
		SEL selector = [NSObject propertyeditorCollectionForGeolocalizationSelectorForProperty:descriptor.name];
		if([subObject respondsToSelector:selector]){
			CKDocumentCollection* collection = [subObject performSelector:selector withObject:valueCoordinate withObject:[NSNumber numberWithFloat:radius]];
			return collection;
		}
		else{
			Class type = descriptor.type;
			if([type respondsToSelector:@selector(editorCollectionAtLocation:radius:)]){
				CKDocumentCollection* collection = [type performSelector:@selector(editorCollectionAtLocation:radius:) withObject:valueCoordinate withObject:[NSNumber numberWithFloat:radius]];
				return collection;
			}
		}
	}
	else{
		Class type = [object class];
		if([type respondsToSelector:@selector(editorCollectionAtLocation:radius:)]){
			CKDocumentCollection* collection = [type performSelector:@selector(editorCollectionAtLocation:radius:) withObject:valueCoordinate withObject:[NSNumber numberWithFloat:radius]];
			return collection;
		}
	}
	return nil;	
}


- (Class)tableViewCellControllerType{
	if(keyPath != nil){
		id subObject = object;
		
		NSArray * ar = [keyPath componentsSeparatedByString:@"."];
		for(int i=0;i<[ar count]-1;++i){
			NSString* path = [ar objectAtIndex:i];
			subObject = [subObject valueForKey:path];
		}
		
		if(subObject == nil){
			NSLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		CKClassPropertyDescriptor* descriptor = [NSObject propertyDescriptor:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
		SEL selector = [NSObject propertyTableViewCellControllerClassSelectorForProperty:descriptor.name];
		if([subObject respondsToSelector:selector]){
			Class controllerClass = [subObject performSelector:selector];
			return controllerClass;
		}
		else{
			Class type = descriptor.type;
			if([type respondsToSelector:@selector(tableViewCellControllerClass)]){
				Class controllerClass = [type performSelector:@selector(tableViewCellControllerClass)];
				return controllerClass;
			}
		}
	}
	else{
		Class type = [object class];
		if([type respondsToSelector:@selector(tableViewCellControllerClass)]){
			Class controllerClass = [type performSelector:@selector(tableViewCellControllerClass)];
			return controllerClass;
		}
	}
	return nil;
}


- (CKModelObjectPropertyMetaData*)metaData{
	if(keyPath != nil){
		id subObject = object;
		
		NSArray * ar = [keyPath componentsSeparatedByString:@"."];
		for(int i=0;i<[ar count]-1;++i){
			NSString* path = [ar objectAtIndex:i];
			subObject = [subObject valueForKey:path];
		}
		
		if(subObject == nil){
			NSLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		CKClassPropertyDescriptor* descriptor = [NSObject propertyDescriptor:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
		CKModelObjectPropertyMetaData* metaData = [CKModelObjectPropertyMetaData propertyMetaDataForObject:subObject property:descriptor];
		return metaData;
	}
	return nil;
}

- (NSString*)name{
	if(keyPath != nil){
		CKClassPropertyDescriptor* descriptor = [self descriptor];
		return descriptor.name;
	}
	return nil;
}

- (id)convertToClass:(Class)type{
	if(keyPath != nil){
		return [NSValueTransformer transformProperty:self toClass:type];
	}
	return [NSValueTransformer transform:object toClass:type];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"%@ \nkeyPath : %@",self.object,self.keyPath];
}

- (BOOL)isReadOnly{
	CKClassPropertyDescriptor* descriptor = [self descriptor];
	return descriptor.isReadOnly;
}

- (void)insertObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes{
	CKClassPropertyDescriptor* descriptor = [self descriptor];
	NSAssert([NSObject isKindOf:descriptor.type parentType:[NSArray class]],@"invalid property type");
	
	if(descriptor.insertSelector && [self.object respondsToSelector:descriptor.insertSelector]){
		[self.object willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
		[self.object performSelector:descriptor.insertSelector withObject:objects withObject:indexes];
		[self.object didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
	}
	else{
		[[self value]insertObjects:objects atIndexes:indexes];
	}
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes{
	CKClassPropertyDescriptor* descriptor = [self descriptor];
	NSAssert([NSObject isKindOf:descriptor.type parentType:[NSArray class]],@"invalid property type");
	
	if(descriptor.removeSelector && [self.object respondsToSelector:descriptor.removeSelector]){
		[self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
		[self.object performSelector:descriptor.removeSelector withObject:indexes];
		[self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
	}
	else{
		[[self value]removeObjectsAtIndexes:indexes];
	}
}

- (void)removeAllObjects{
	CKClassPropertyDescriptor* descriptor = [self descriptor];
	NSAssert([NSObject isKindOf:descriptor.type parentType:[NSArray class]],@"invalid property type");
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[[self value] count])];
	[self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
	if(descriptor.removeAllSelector && [self.object respondsToSelector:descriptor.removeAllSelector]){
		[self.object performSelector:descriptor.removeAllSelector];
	}
	else{
		[[self value]removeAllObjects];
	}
	
	[self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
}

@end
