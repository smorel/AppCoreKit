//
//  CKObjectKeyValue.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectProperty.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKDocumentCollection.h"

@interface CKObjectProperty()
@property (nonatomic,retain) id subObject;
@property (nonatomic,retain) NSString* subKeyPath;
@property (nonatomic,retain,readwrite) id object;
@property (nonatomic,retain,readwrite) NSString* keyPath;
@property (nonatomic,retain,readwrite) CKClassPropertyDescriptor* descriptor;
@end

@implementation CKObjectProperty
@synthesize object,keyPath;
@synthesize subObject,subKeyPath;
@synthesize descriptor;

- (void)dealloc{
    self.object = nil;
    self.keyPath = nil;
    self.subObject = nil;
    self.subKeyPath = nil;
    self.descriptor = nil;
	[super dealloc];
}

+ (CKObjectProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath{
	CKObjectProperty* p = [[[CKObjectProperty alloc]initWithObject:object keyPath:keyPath]autorelease];
	return p;
}

- (void)postInit{
    self.subObject = object;
	if(self.keyPath){
        NSArray * ar = [self.keyPath componentsSeparatedByString:@"."];
        for(int i=0;i<[ar count]-1;++i){
            NSString* path = [ar objectAtIndex:i];
            self.subObject = [self.subObject valueForKey:path];
        }
        self.subKeyPath = ([ar count] > 0) ? [ar objectAtIndex:[ar count] -1 ] : nil;
    }
    else{
        self.subKeyPath = nil;
    }
    
    if(self.subObject && self.subKeyPath){
        self.descriptor = [NSObject propertyDescriptor:[self.subObject class] forKey:self.subKeyPath];
    }
    else{
        self.descriptor = nil;
    }
}

- (id)initWithObject:(id)theobject keyPath:(NSString*)thekeyPath{
	[super init];
	self.object = theobject;
    if([thekeyPath length] > 0){
        self.keyPath = thekeyPath;
    }
    [self postInit];
	return self;
}

+ (CKObjectProperty*)propertyWithObject:(id)object{
	CKObjectProperty* p = [[[CKObjectProperty alloc]initWithObject:object]autorelease];
	return p;
}

- (id)initWithObject:(id)theobject{
	[super init];
	self.object = theobject;
    [self postInit];
	return self;
}

- (Class)type{
    if(self.keyPath == nil)
        return [self.object class];
    return self.descriptor.type;
}

- (id)value{
	return (self.subKeyPath != nil) ? [self.subObject valueForKey:self.subKeyPath] : self.subObject;
}

- (void)setValue:(id)value{
	if(self.subKeyPath != nil && [[self value] isEqual:value] == NO){
		[self.subObject setValue:value forKey:self.subKeyPath];
	}
	else if(self.subKeyPath == nil){
		[self.subObject copy:value];
	}
}

- (CKDocumentCollection*)editorCollectionWithFilter:(NSString*)filter{
	if(keyPath != nil){
		if(self.subObject == nil){
			NSLog(@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		SEL selector = [NSObject propertyeditorCollectionSelectorForProperty:self.descriptor.name];
		if([self.subObject respondsToSelector:selector]){
			CKDocumentCollection* collection = [self.subObject performSelector:selector withObject:filter];
			return collection;
		}
		else{
			Class type = self.descriptor.type;
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
		if(self.subObject == nil){
			NSLog(@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		SEL selector = [NSObject propertyeditorCollectionForNewlyCreatedSelectorForProperty:self.descriptor.name];
		if([self.subObject respondsToSelector:selector]){
			CKDocumentCollection* collection = [self.subObject performSelector:selector];
			return collection;
		}
		else{
			Class type = self.descriptor.type;
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
		if(self.subObject == nil){
			NSLog(self.subObject,@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		SEL selector = [NSObject propertyeditorCollectionForGeolocalizationSelectorForProperty:self.descriptor.name];
		if([self.subObject respondsToSelector:selector]){
			CKDocumentCollection* collection = [self.subObject performSelector:selector withObject:valueCoordinate withObject:[NSNumber numberWithFloat:radius]];
			return collection;
		}
		else{
			Class type = self.descriptor.type;
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
		if(self.subObject == nil){
			NSLog(@"unable to find property '%@' in '%@'",keyPath,object);
			return nil;
		}
		
		SEL selector = [NSObject propertyTableViewCellControllerClassSelectorForProperty:self.descriptor.name];
		if([self.subObject respondsToSelector:selector]){
			Class controllerClass = [self.subObject performSelector:selector];
			return controllerClass;
		}
		else{
			Class type = self.descriptor.type;
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
	if(self.descriptor != nil){
		return [CKModelObjectPropertyMetaData propertyMetaDataForObject:self.subObject property:self.descriptor];
	}
	return nil;
}

- (NSString*)name{
	if(self.descriptor != nil){
		return self.descriptor.name;
	}
	return nil;
}

- (id)convertToClass:(Class)type{
	if(self.descriptor != nil){
		return [NSValueTransformer transformProperty:self toClass:type];
	}
	return [NSValueTransformer transform:object toClass:type];
}

- (NSString*)description{
	return [NSString stringWithFormat:@"%@ \nkeyPath : %@",self.object,self.keyPath];
}

- (BOOL)isReadOnly{
	return self.descriptor.isReadOnly;
}

- (void)insertObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes{
	Class selfClass = [self type];
    if([NSObject isKindOf:selfClass parentType:[CKDocumentCollection class]]){
        [[self value]insertObjects:objects atIndexes:indexes];
        return;
    }
	NSAssert([NSObject isKindOf:selfClass parentType:[NSArray class]],@"invalid property type");
	
    if([NSObject isKindOf:selfClass parentType:[NSArray class]]){
        if(self.descriptor && self.descriptor.insertSelector && [self.object respondsToSelector:self.descriptor.insertSelector]){
            [self.object willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
            [self.object performSelector:self.descriptor.insertSelector withObject:objects withObject:indexes];
            [self.object didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
        }
        else{
            [[self value]insertObjects:objects atIndexes:indexes];
        }
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes{
	Class selfClass = [self type];
    if([NSObject isKindOf:selfClass parentType:[CKDocumentCollection class]]){
		[[self value]removeObjectsAtIndexes:indexes];
        return;
    }
	NSAssert([NSObject isKindOf:selfClass parentType:[NSArray class]],@"invalid property type");
	
	if(self.descriptor && self.descriptor.removeSelector && [self.object respondsToSelector:self.descriptor.removeSelector]){
		[self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
		[self.object performSelector:self.descriptor.removeSelector withObject:indexes];
		[self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
	}
	else{
		[[self value]removeObjectsAtIndexes:indexes];
	}
}

- (void)removeAllObjects{
	Class selfClass = [self type];
    if([NSObject isKindOf:selfClass parentType:[CKDocumentCollection class]]){
        [[self value]removeAllObjects];
        return;
    }
	NSAssert([NSObject isKindOf:selfClass parentType:[NSArray class]],@"invalid property type");
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[[self value] count])];
	[self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
    
	if(self.descriptor && self.descriptor.removeAllSelector && [self.object respondsToSelector:self.descriptor.removeAllSelector]){
		[self.object performSelector:self.descriptor.removeAllSelector];
	}
	else{
		[[self value]removeAllObjects];
	}
	
	[self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
}


- (NSInteger)count{
	Class selfClass = [self type];
	NSAssert([NSObject isKindOf:selfClass parentType:[NSArray class]]
             ||[NSObject isKindOf:selfClass parentType:[CKDocumentCollection class]],@"invalid property type");
    return [[self value]count];
}

@end
