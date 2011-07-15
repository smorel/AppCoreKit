//
//  ObjectIntrospection.m
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSObject+Introspection.h"
#import <objc/runtime.h>
#import <Foundation/NSKeyValueCoding.h>
#import <malloc/malloc.h>

#include <execinfo.h>
#import "CKUIView+Introspection.h"

static NSString* getPropertyType(objc_property_t property) {
	if(property){
		const char *attributes = property_getAttributes(property);
		char buffer[1 + strlen(attributes)];
		strcpy(buffer, attributes);
		char *state = buffer, *attribute;
		while ((attribute = strsep(&state, ",")) != NULL) {
			if(strlen(attribute) > 4){
				if (attribute[0] == 'T' && attribute[1] == '@') {
					return [[NSString stringWithUTF8String:attribute] substringWithRange: NSMakeRange(3, strlen(attribute)-4)];
				}
			}
		}
	}
    return @"";
}


@interface NSObject ()
- (void)filterProperties:(NSMutableArray*)results 
					explored:(NSMutableSet*)explored 
					instance:(id)instance 
					expandWith:(CKObjectPredicate)expandWith 
					insertWith:(CKObjectPredicate)insertWith;

- (void) filterObjects : (NSMutableArray*)results 
				    explored:(NSMutableSet*)explored 
					instance:(id)instance 
				    expandWith:(CKObjectPredicate)expandWith 
				    insertWith:(CKObjectPredicate)insertWith 
				    addInstance:(BOOL)addInstance;

+ (NSString*)concatenateAndUpperCaseFirstChar:(NSString*)input prefix:(NSString*)prefix suffix:(NSString*)suffix;
@end


@implementation NSObject (CKNSObjectIntrospection)

+(CKClassPropertyDescriptor*)propertyForDescriptor:(objc_property_t)descriptor{
	const char *propName = property_getName(descriptor);
	if(propName) {
		//const char *propType = getPropertyType(property);
		const char *attributes = property_getAttributes(descriptor);
		
		NSString *propType = getPropertyType(descriptor);
		Class returnType = NSClassFromString(propType);
		
		CKClassPropertyDescriptor* objectProperty = [[[CKClassPropertyDescriptor alloc]init]autorelease];
		objectProperty.name = [NSString stringWithUTF8String:propName];
		objectProperty.type = returnType;
		objectProperty.className = [NSString stringWithUTF8String:class_getName(returnType)];
		objectProperty.attributes = [NSString stringWithUTF8String:attributes];
		objectProperty.metaDataSelector = [NSObject propertyMetaDataSelectorForProperty:objectProperty.name];
		
		if([NSObject isKindOf:returnType parentType:[NSArray class]]){
			objectProperty.insertSelector = [NSObject insertSelectorForProperty:objectProperty.name];
			objectProperty.removeSelector = [NSObject removeSelectorForProperty:objectProperty.name];
			objectProperty.removeAllSelector = [NSObject removeAllSelectorForProperty:objectProperty.name];
		}
		
		return objectProperty;
	}
	return nil;
}

+(CKClassPropertyDescriptor*) propertyDescriptor:(id)object forKeyPath:(NSString*)keyPath{
	//NSLog(@"finding property:'%@' in '%@'",keyPath,object);
	id subObject = object;
	
	NSArray * ar = [keyPath componentsSeparatedByString:@"."];
	for(int i=0;i<[ar count]-1;++i){
		NSString* path = [ar objectAtIndex:i];
		//NSLog(@"\tsub finding property:'%@' in '%@'",path,subObject);
		subObject = [subObject valueForKey:path];
	}
	if(subObject == nil){
		NSLog(subObject,@"unable to find property '%@' in '%@'",keyPath,object);
		return nil;
	}
	return [self propertyDescriptor:[subObject class] forKey:[ar objectAtIndex:[ar count] -1 ]];
}

+(CKClassPropertyDescriptor*) propertyDescriptor:(Class)c forKey:(NSString*)name{
	return [[CKClassPropertyDescriptorManager defaultManager]property:name forClass:[c class]];
}


- (CKClassPropertyDescriptor*) propertyDescriptorForKeyPath:(NSString*)keyPath{
	return [NSObject propertyDescriptor:[self class] forKeyPath:keyPath];
}

- (void)_introspection:(Class)c array:(NSMutableArray*)array{
	unsigned int outCount, i;
    objc_property_t *ps = class_copyPropertyList(c, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = ps[i];
        CKClassPropertyDescriptor* objectProperty = [NSObject propertyForDescriptor:property ];
		[array addObject:objectProperty];
    }
    free(ps);	
	
	/*
	 Ivar * ivs = class_copyIvarList(c, &outCount);
	 for(i = 0; i < outCount; i++){
	 Ivar v = ivs[i];
	 int i =3;
	 }
	 free(ivs);	
	 */
	
	Class f = class_getSuperclass(c);
	if(f && ![NSObject isExactKindOf:f parentType:[NSObject class]]){
		[self _introspection:f array:array];
	}
	
}

- (void)introspection:(Class)c array:(NSMutableArray*)array{
	[self _introspection:c array:array];
	if([c respondsToSelector:@selector(additionalClassPropertyDescriptors)]){
		NSArray* additionalProperties = [c performSelector:@selector(additionalClassPropertyDescriptors)];
		[array addObjectsFromArray:additionalProperties];
	}
}

- (NSArray*)allViewsPropertyDescriptors{
	return [[CKClassPropertyDescriptorManager defaultManager]allViewsPropertyForClass:[self class]];
}

- (NSArray*)allPropertyDescriptors{
	return [[CKClassPropertyDescriptorManager defaultManager]allPropertiesForClass:[self class]];
}

- (NSArray*)allPropertyNames{
	return [[CKClassPropertyDescriptorManager defaultManager]allPropertieNamesForClass:[self class]];
}


- (NSString*)className{
	return NSStringFromClass([self class]);//[NSString stringWithUTF8String:class_getName([self class])];
}

+ (BOOL)isKindOf:(Class)type parentType:(Class)parentType{
	if(parentType){
		if([NSObject isExactKindOf:type parentType:parentType])
			return YES;
		Class p = class_getSuperclass(type);
		if(p)
			return [NSObject isKindOf:p parentType:parentType];
		return NO;
	}
	return YES;
}

+ (BOOL)isExactKindOf:(Class)type parentType:(Class)parentType{
	if(parentType){
		const char* t1 = class_getName(type);
		const char* t2 = class_getName(parentType);
		if(strcmp(t1,t2) == 0)
			return YES;
		return NO;
	}
	return YES;
}

- (void)filterProperties:(NSMutableArray*)results 
					explored:(NSMutableSet*)explored 
					instance:(id)instance 
					expandWith:(CKObjectPredicate)expandWith 
					insertWith:(CKObjectPredicate)insertWith 
{
	if(instance && [instance conformsToProtocol:@protocol(NSObject)]){
		NSArray* properties = [instance allPropertyDescriptors];
		for(CKClassPropertyDescriptor* property in properties){
			if(property && property.propertyType == CKClassPropertyDescriptorTypeObject){
				id instanceProperty = [instance valueForKey:property.name];
				if(instanceProperty){
					[self filterObjects:results explored:explored instance:instanceProperty expandWith:expandWith insertWith:insertWith addInstance:YES];
				}
			}
		}
	}
		
}

- (void) filterObjects : (NSMutableArray*)results 
					 explored:(NSMutableSet*)explored 
					 instance:(id)instance 
				     expandWith:(CKObjectPredicate)expandWith 
				     insertWith:(CKObjectPredicate)insertWith 
				     addInstance:(BOOL)addInstance
{
	if(instance && ![explored containsObject:instance]){//avoid recursions
		[explored addObject:instance];
		if(addInstance && insertWith(instance)){
			[results addObject:instance];
		}
		
		if(expandWith(instance)){
			//Handle collections
			if([instance conformsToProtocol:@protocol(NSFastEnumeration)]){
				for(id subInstance in instance){
					[self filterObjects:results explored:explored instance:subInstance expandWith:expandWith insertWith:insertWith addInstance:YES];
				}
			}
			else{
				//And properties
				[self filterProperties:results explored:explored instance:instance expandWith:expandWith insertWith:insertWith];
			}
		}
	}
}

- (NSMutableArray*)subObjects :(CKObjectPredicate)expandWith insertWith:(CKObjectPredicate)insertWith includeSelf:(BOOL)includeSelf{
	NSMutableSet* objectsExplored = [NSMutableSet set];
	NSMutableArray* results = [NSMutableArray array];
	[self filterObjects:results explored:objectsExplored instance:self expandWith:expandWith insertWith:insertWith addInstance:includeSelf];
	return results;
}

- (int)memorySizeIncludingSubObjects : (BOOL)includeSubObjects{
	NSMutableArray* objects = [self subObjects:^(id object){return [object isKindOfClass:[NSObject class]];} 
									insertWith:^(id object){return [object isKindOfClass:[NSObject class]];} 
								    includeSelf:YES];
	int total = 0;
	for(NSObject* obj in objects){
		total += malloc_size(obj);
	}
	return total;
}

+ (NSString*)concatenateAndUpperCaseFirstChar:(NSString*)input prefix:(NSString*)prefix suffix:(NSString*)suffix{
	NSString* firstChar = [input substringWithRange: NSMakeRange (0, 1)];
	NSString* rest = [input substringWithRange: NSMakeRange (1, [input length] - 1)];
	return [NSString stringWithFormat:@"%@%@%@%@",prefix,[firstChar uppercaseString],rest,suffix];
}

+ (SEL)selectorForProperty:(NSString*)property prefix:(NSString*)prefix suffix:(NSString*)suffix{
	NSAssert(prefix && (prefix.length > 0), @"prefix should not be empty.");
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:property prefix:prefix suffix:suffix];
	return NSSelectorFromString(selectorName);
}

+ (SEL)selectorForProperty:(NSString*)property suffix:(NSString*)suffix{
	NSString* selectorName = [NSString stringWithFormat:@"%@%@",property,suffix];
	return NSSelectorFromString(selectorName);
}

+ (SEL)insertorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"add" suffix:@"Object:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)keyValueInsertorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"add" suffix:@"Object:forKey:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)typeCheckSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"is" suffix:@"CompatibleWith:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)setSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"set" suffix:@":"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)propertyMetaDataSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [NSString stringWithFormat:@"%@MetaData:",propertyName];
	return NSSelectorFromString(selectorName);
}

+ (SEL)propertyeditorCollectionSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [NSString stringWithFormat:@"%@EditorCollectionWithFilter:",propertyName];
	return NSSelectorFromString(selectorName);
}

+ (SEL)propertyeditorCollectionForNewlyCreatedSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [NSString stringWithFormat:@"%@EditorCollectionForNewlyCreated",propertyName];
	return NSSelectorFromString(selectorName);
}

+ (SEL)propertyeditorCollectionForGeolocalizationSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [NSString stringWithFormat:@"%@EditorCollectionAtLocation:radius",propertyName];
	return NSSelectorFromString(selectorName);
}

+ (SEL)propertyTableViewCellControllerClassSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [NSString stringWithFormat:@"%@TableViewCellControllerClass",propertyName];
	return NSSelectorFromString(selectorName);
}


+ (SEL)insertSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"insert" suffix:@"Objects:atIndexes:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)removeSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"remove" suffix:@"ObjectsAtIndexes:"];
	return NSSelectorFromString(selectorName);
}

+ (SEL)removeAllSelectorForProperty : (NSString*)propertyName{
	NSString* selectorName = [self concatenateAndUpperCaseFirstChar:propertyName prefix:@"removeAll" suffix:@"Objects"];
	return NSSelectorFromString(selectorName);
}

@end
