//
//  CKObjectKeyValue.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectProperty.h"


@implementation CKObjectProperty
@synthesize object,keyPath;

- (id)initWithObject:(id)theobject keyPath:(NSString*)thekeyPath{
	[super init];
	self.object = theobject;
	self.keyPath = thekeyPath;
	return self;
}

- (CKClassPropertyDescriptor*)descriptor{
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
	return [object valueForKeyPath:keyPath];
}

- (void)setValue:(id)value{
	[object setValue:value forKeyPath:keyPath];
}

- (CKDocumentCollection*)editorCollection{
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
	CKDocumentCollection* collection = [subObject performSelector:descriptor.editorCollectionSelector];
	
	return collection;
}


- (CKModelObjectPropertyMetaData*)metaData{
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

@end
