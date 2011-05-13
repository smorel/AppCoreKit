//
//  ObjectIntrospection.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


/*
 The property is read-only (readonly).
 C
 The property is a copy of the value last assigned (copy).
 &
 The property is a reference to the value last assigned (retain).
 N
 The property is non-atomic (nonatomic).
 G<name>
 The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
 S<name>
 The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
 D
 The property is dynamic (@dynamic).
 W
 The property is a weak reference (__weak).
 P
 The property is eligible for garbage collection.
 */

#import "CKClassPropertyDescriptor.h"

typedef BOOL(^CKObjectPredicate)(id);


@interface NSObject (CKNSObjectIntrospection)

- (NSString*)className;
+ (BOOL)isKindOf:(Class)type parentType:(Class)parentType;
+ (BOOL)isExactKindOf:(Class)type parentType:(Class)parentType;

- (NSArray*)allViewsPropertyDescriptors;
- (NSArray*)allPropertyDescriptors;
- (NSArray*)allPropertyNames;

- (NSMutableArray*)subObjects :(CKObjectPredicate)expandWith insertWith:(CKObjectPredicate)insertWith includeSelf:(BOOL)includeSelf;

+ (NSString*)concatenateAndUpperCaseFirstChar:(NSString*)input prefix:(NSString*)prefix suffix:(NSString*)suffix;
+ (SEL)selectorForProperty:(NSString*)property prefix:(NSString*)prefix suffix:(NSString*)suffix;
+ (SEL)selectorForProperty:(NSString*)property suffix:(NSString*)suffix;
+ (SEL)insertorForProperty : (NSString*)propertyName;
+ (SEL)keyValueInsertorForProperty : (NSString*)propertyName;
+ (SEL)typeCheckSelectorForProperty : (NSString*)propertyName;
+ (SEL)setSelectorForProperty : (NSString*)propertyName;
+ (SEL)propertyMetaDataSelectorForProperty : (NSString*)propertyName;
+ (SEL)propertyeditorCollectionSelectorForProperty : (NSString*)propertyName;
+ (SEL)propertyTableViewCellControllerClassSelectorForProperty : (NSString*)propertyName;

+(CKClassPropertyDescriptor*) propertyDescriptor:(Class)c forKey:(NSString*)name;
+(CKClassPropertyDescriptor*) propertyDescriptor:(id)object forKeyPath:(NSString*)keyPath;

-(CKClassPropertyDescriptor*) propertyDescriptorForKeyPath:(NSString*)keyPath;

- (int)memorySizeIncludingSubObjects : (BOOL)includeSubObjects;
- (void)introspection:(Class)c array:(NSMutableArray*)array;

@end

@interface NSObject (CKNSObjectDebugStack)
+ (NSString*)callStack;
+ (void)logCallStack;
+ (void)logCallStackIfBlockCopy;
@end
