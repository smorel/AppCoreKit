//
//  ObjectIntrospection.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


typedef BOOL(^CKObjectPredicate)(id);
CKObjectPredicate CKObjectPredicateMakeIsOfType(Class type1,...);
CKObjectPredicate CKObjectPredicateMakeIsNotOfType(Class type1,...);
CKObjectPredicate CKObjectPredicateMakeExpandAll();



@interface CKObjectProperty : NSObject{
	NSString* name;
	Class type;
	BOOL isObject;
	BOOL isSelector;
	NSString* attributes;
}

@property (nonatomic, retain, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) Class type;
@property (nonatomic, retain, readwrite) NSString *attributes;
@property (nonatomic, assign, readwrite) BOOL isObject;
@property (nonatomic, assign, readwrite) BOOL isSelector;

-(NSString*)getTypeDescriptor;

@end


@interface NSObject (CKNSObjectIntrospection)


+ (BOOL)isKindOf:(Class)type parentType:(Class)parentType;
- (NSMutableArray*)allProperties;

- (NSMutableArray*)subObjects :(CKObjectPredicate)expandWith insertWith:(CKObjectPredicate)insertWith includeSelf:(BOOL)includeSelf;

- (SEL)insertorForProperty : (NSString*)propertyName;
- (SEL)keyValueInsertorForProperty : (NSString*)propertyName;
- (SEL)typeCheckSelectorForProperty : (NSString*)propertyName;
- (SEL)setSelectorForProperty : (NSString*)propertyName;

+(CKObjectProperty*) property:(Class)c name:(NSString*)name;

@end
