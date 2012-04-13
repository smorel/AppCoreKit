//
//  CKProperty.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKProperty.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKDocumentCollection.h"
#import "CKNSObject+CKRuntime.h"
#import "CKWeakRef.h"
#import "CKDebug.h"
#import "CKNSObject+CKRuntime_private.h"

@interface CKProperty()
@property (nonatomic,retain) CKWeakRef* subObject;
@property (nonatomic,retain) NSString* subKeyPath;
@property (nonatomic,retain) CKWeakRef* objectRef;
@property (nonatomic,retain,readwrite) id keyPath;
@property (nonatomic,retain,readwrite) CKClassPropertyDescriptor* descriptor;
- (void)postInit;
@end

@implementation CKProperty
@synthesize object,keyPath;
@synthesize subObject,subKeyPath;
@synthesize descriptor;
@synthesize objectRef;

- (void)dealloc{
    self.objectRef = nil;
    self.keyPath = nil;
    self.subObject = nil;
    self.subKeyPath = nil;
    self.descriptor = nil;
	[super dealloc];
}

+ (CKProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath{
	CKProperty* p = [[[CKProperty alloc]initWithObject:object keyPath:keyPath]autorelease];
	return p;
}

+ (CKProperty*)propertyWithObject:(id)object{
	CKProperty* p = [[[CKProperty alloc]initWithObject:object]autorelease];
	return p;
}

+ (CKProperty*)propertyWithDictionary:(id)dictionary key:(id)key{
	CKProperty* p = [[[CKProperty alloc]initWithDictionary:dictionary key:key]autorelease];
	return p;
}

- (id)initWithObject:(id)theobject keyPath:(NSString*)thekeyPath{
	[super init];
    self.objectRef = [CKWeakRef weakRefWithObject:theobject target:self action:@selector(releaseObject:)];
    if([thekeyPath length] > 0){
        self.keyPath = thekeyPath;
    }
    [self postInit];
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary key:(id)key{
    [super init];
    self.objectRef = [CKWeakRef weakRefWithObject:dictionary target:self action:@selector(releaseObject:)];
    self.keyPath = key;
    [self postInit];
	return self;
}

- (id)initWithObject:(id)theobject{
	[super init];
    self.objectRef = [CKWeakRef weakRefWithObject:theobject target:self action:@selector(releaseObject:)];
    [self postInit];
	return self;
}

- (id)releaseSubObject:(CKWeakRef*)weakRef{
    self.subKeyPath = nil;
    return nil;
}

- (id)releaseObject:(CKWeakRef*)weakRef{
    self.keyPath = nil;
    return nil;
}

- (id)object{
    return self.objectRef.object;
}

- (void)postInit{
    id target = self.object;
    if([target isKindOfClass:[NSDictionary class]]){
        id value = [target objectForKey:self.keyPath];
        NSString* name = [NSValueTransformer transform:self.keyPath toClass:[NSString class]];
        self.descriptor = [CKClassPropertyDescriptor classDescriptorForPropertyNamed:name withClass:[value class] assignment:CKClassPropertyDescriptorAssignementTypeRetain readOnly:YES];
    }
    else{
        if(self.keyPath){
            NSArray * ar = [self.keyPath componentsSeparatedByString:@"."];
            for(int i=0;i<[ar count]-1;++i){
                NSString* path = [ar objectAtIndex:i];
                target = [target valueForKey:path];
            }
            self.subKeyPath = ([ar count] > 0) ? [ar objectAtIndex:[ar count] -1 ] : nil;
        }
        else{
            self.subKeyPath = nil;
        }
        
        
        self.subObject = [CKWeakRef weakRefWithObject:target target:self action:@selector(releaseSubObject:)];
        if(self.subObject.object && self.subKeyPath){
            self.descriptor = [NSObject propertyDescriptorForClass:[self.subObject.object class] key:self.subKeyPath];
        }
        else{
            self.descriptor = nil;
        }
    }
}

- (Class)type{
    if(self.keyPath == nil)
        return [self.object class];
    return self.descriptor.type;
}

- (id)value{
    if([self.object isKindOfClass:[NSDictionary class]]){
        return [self.object objectForKey:self.keyPath];
    }
	return (self.subKeyPath != nil) ? [self.subObject.object valueForKey:self.subKeyPath] : self.subObject.object;
}

- (void)setValue:(id)value{
    if([self.object isKindOfClass:[NSDictionary class]]){
        [self.object setObject:value forKey:self.keyPath];
    }
    else if([self descriptor].propertyType == CKClassPropertyDescriptorTypeSelector){
        SEL selector = [NSObject selectorForProperty:[self descriptor].name prefix:@"set" suffix:@":"];
        SEL selValue = [value pointerValue];
        
        NSMethodSignature *signature = [self.subObject.object methodSignatureForSelector:selector];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:self.subObject.object];
        [invocation setArgument:&selValue
                        atIndex:2];
        [invocation invoke];
    }
	else if(self.subKeyPath != nil && [[self value] isEqual:value] == NO){
		[self.subObject.object setValue:value forKey:self.subKeyPath];
	}
	else if(self.subKeyPath == nil){
		[self.subObject.object copyPropertiesFromObject:value];
	}
}


- (CKPropertyExtendedAttributes*)extendedAttributes{
	if(self.descriptor != nil){
		return [self.descriptor extendedAttributesForInstance:self.subObject.object];
	}
	return nil;
}

- (NSString*)name{
    if(self.descriptor != nil){
		return self.descriptor.name;
	}
	return self.keyPath;
}

- (NSString*)description{
	return [NSString stringWithFormat:@"%@ \nkeyPath : %@",self.object,self.keyPath];
}

- (BOOL)isReadOnly{
	return self.descriptor.isReadOnly;
}

- (void)insertObjects:(NSArray*)objects atIndexes:(NSIndexSet*)indexes{
	Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKDocumentCollection class]]){
        [[self value]insertObjects:objects atIndexes:indexes];
        return;
    }
	NSAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
	
    if([NSObject isClass:selfClass kindOfClass:[NSArray class]]){
        if(self.descriptor && self.descriptor.insertSelector && [self.object respondsToSelector:self.descriptor.insertSelector]){
            [self.object willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
            [self.object performSelector:self.descriptor.insertSelector withObject:objects withObject:indexes];
            [self.object didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
        }
        else{
            id proxy= nil;
            if(self.subKeyPath != nil) {
                proxy = [self.subObject.object mutableArrayValueForKey:self.subKeyPath];
            }
            else{
                proxy = self.subObject.object;
            }
            [proxy insertObjects:objects atIndexes:indexes];
        }
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes{
	Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKDocumentCollection class]]){
		[[self value]removeObjectsAtIndexes:indexes];
        return;
    }
	NSAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
	
	if(self.descriptor && self.descriptor.removeSelector && [self.object respondsToSelector:self.descriptor.removeSelector]){
		[self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
		[self.object performSelector:self.descriptor.removeSelector withObject:indexes];
		[self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
	}
	else{
        id proxy= nil;
        if(self.subKeyPath != nil) {
            proxy = [self.subObject.object mutableArrayValueForKey:self.subKeyPath];
        }
        else{
            proxy = self.subObject.object;
        }
		[proxy removeObjectsAtIndexes:indexes];
	}
}

- (void)removeAllObjects{
	Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKDocumentCollection class]]){
        [[self value]removeAllObjects];
        return;
    }
	NSAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[[self value] count])];
	    
	if(self.descriptor && self.descriptor.removeAllSelector && [self.object respondsToSelector:self.descriptor.removeAllSelector]){
        [self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
		[self.object performSelector:self.descriptor.removeAllSelector];
        [self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
	}
	else{
        NSMutableArray* proxy= nil;
        if(self.subKeyPath != nil) {
            proxy = [self.subObject.object mutableArrayValueForKey:self.subKeyPath];
        }
        else{
            proxy = self.subObject.object;
        }
		[proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [proxy count])]];
	}
}

- (NSInteger)count{
	Class selfClass = [self type];
	NSAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]]
             ||[NSObject isClass:selfClass kindOfClass:[CKDocumentCollection class]],@"invalid property type");
    return [[self value]count];
}

- (id) copyWithZone:(NSZone *)zone {
    return [[CKProperty alloc]initWithObject:self.object keyPath:self.keyPath];
}

@end
