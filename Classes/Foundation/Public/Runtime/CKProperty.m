//
//  CKProperty.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKProperty.h"
#import "NSValueTransformer+Additions.h"
#import "CKCollection.h"
#import "NSObject+Runtime.h"
#import "CKDebug.h"
#import "NSObject+Runtime_private.h"

@interface CKProperty()
@property (nonatomic,assign,readwrite) BOOL weak;
@property (nonatomic,retain) id subObject;
@property (nonatomic,retain) NSString* subKeyPath;
@property (nonatomic,retain,readwrite) id object;
@property (nonatomic,retain,readwrite) id keyPath;
@property (nonatomic,retain,readwrite) CKClassPropertyDescriptor* descriptor;
@property (nonatomic,retain) NSString* hashValue;
- (void)postInit;
@end

@implementation CKProperty
@synthesize object = _object,keyPath;
@synthesize subObject = _subObject,subKeyPath;
@synthesize descriptor;
@synthesize weak;
@synthesize hashValue;

- (void)dealloc{
    self.object = nil;
    self.keyPath = nil;
    self.subObject = nil;
    self.subKeyPath = nil;
    self.descriptor = nil;
    self.hashValue = nil;
	[super dealloc];
}

+ (CKProperty*)weakPropertyWithObject:(id)object keyPath:(NSString*)keyPath{
	CKProperty* p = [[[CKProperty alloc]initWithObject:object keyPath:keyPath weak:YES]autorelease];
	return p;
}

+ (CKProperty*)weakPropertyWithObject:(id)object{
	CKProperty* p = [[[CKProperty alloc]initWithObject:object weak:YES]autorelease];
	return p;
}

+ (CKProperty*)propertyWithObject:(id)object keyPath:(NSString*)keyPath{
	CKProperty* p = [[[CKProperty alloc]initWithObject:object keyPath:keyPath weak:NO]autorelease];
	return p;
}

+ (CKProperty*)propertyWithObject:(id)object{
	CKProperty* p = [[[CKProperty alloc]initWithObject:object weak:NO]autorelease];
	return p;
}

+ (CKProperty*)propertyWithDictionary:(id)dictionary key:(id)key{
	CKProperty* p = [[[CKProperty alloc]initWithDictionary:dictionary key:key]autorelease];
	return p;
}

- (void)setObject:(id)theobject{
    if(self.weak){
        _object = theobject;
    }else{
        [_object release];
        _object = [theobject retain];
    }
}

- (void)setSubObject:(id)thesubObject{
    if(self.weak){
        _subObject = thesubObject;
    }else{
        [_subObject release];
        _subObject = [thesubObject retain];
    }
}

- (id)initWithObject:(id)theobject keyPath:(NSString*)thekeyPath weak:(BOOL)boweak{
	if (self = [super init]) {
        self.weak = boweak;
        self.object = theobject;
        if([thekeyPath length] > 0){
            self.keyPath = thekeyPath;
        }
        [self postInit];    
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary key:(id)key{
    if (self = [super init]) {
        self.object = dictionary;
        self.keyPath = key;
        [self postInit];
    }
	return self;
}

- (id)initWithObject:(id)theobject weak:(BOOL)boweak{
	if (self = [super init]) {
        self.weak = boweak;
        self.object = theobject;
        [self postInit];
    }
	return self;
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
            if([self.keyPath rangeOfString:@"."].location != NSNotFound){
                NSArray * ar = [self.keyPath componentsSeparatedByString:@"."];
                for(int i=0;i<[ar count]-1;++i){
                    NSString* path = [ar objectAtIndex:i];
                    CKClassPropertyDescriptor* pathDescriptor = [target propertyDescriptorForKeyPath:path];
                    if(pathDescriptor){
                        target = [target valueForKey:path];
                    }
                }
                self.subKeyPath = ([ar count] > 0) ? [ar objectAtIndex:[ar count] -1 ] : nil;
            }else{
                self.subKeyPath = self.keyPath;
            }
        }
        else{
            self.subKeyPath = nil;
        }
        
        
        self.subObject = target;
        
        if(self.subObject && self.subKeyPath){
            self.descriptor = [NSObject propertyDescriptorForClass:[self.subObject class] key:self.subKeyPath];
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
    
    @try{
        return (self.subKeyPath != nil) ? [self.subObject valueForKey:self.subKeyPath] : self.subObject;
    }
    @catch (NSException* e) {
        CKDebugLog(@"%@",e);
        return nil;
    }
}


- (BOOL)isKVCComplient{
    if([self.object isKindOfClass:[NSDictionary class]]){
        return YES;
    }
    if(self.subKeyPath == nil)
        return YES;
    
    //FIXME: find another way to do this as it is intense on the CPU while profiling ! And it is a real pain when having an exception breakpoint!
    
    /* @try{
         [self.subObject valueForKey:self.subKeyPath];
    }
    @catch (NSException* e) {
        return NO;
    } */
    
    return YES;
}

- (void)setValue:(id)value{
    if([self isReadOnly]){
        //supports for readonly arrays (like subviews on UIView) with insert/remove runtime extension
        if([value isKindOfClass:[NSArray class]]){
            [self insertObjects:value atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.count, [value count])]];
            return;
        }
        
        NSLog(@"Could not set value %@ to readonly property %@",value,self);
        return;
    }
    
    if([self.object isKindOfClass:[NSDictionary class]]){
        [self.object setObject:value forKey:self.keyPath];
    }
    else if([self descriptor].propertyType == CKClassPropertyDescriptorTypeSelector){
        SEL selector = [NSObject selectorForProperty:[self descriptor].name prefix:@"set" suffix:@":"];
        SEL selValue = [value pointerValue];
        
        NSMethodSignature *signature = [self.subObject methodSignatureForSelector:selector];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:selector];
        [invocation setTarget:self.subObject];
        [invocation setArgument:&selValue
                        atIndex:2];
        [invocation invoke];
    }
	else if(self.subKeyPath != nil){
        @try{
            [self.subObject setValue:value forKey:self.subKeyPath];
        }
        @catch (NSException* e) {
            CKDebugLog(@"%@",e);
        }
	}
	else if(self.subKeyPath == nil){
		[self.subObject copyPropertiesFromObject:value];
	}
}


- (CKPropertyExtendedAttributes*)extendedAttributes{
	if(self.descriptor != nil){
		return [self.descriptor extendedAttributesForInstance:self.subObject];
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
    if([NSObject isClass:selfClass kindOfClass:[CKCollection class]]){
        [[self value]insertObjects:objects atIndexes:indexes];
        return;
    }
	CKAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
	
    if([NSObject isClass:selfClass kindOfClass:[NSArray class]]){
        if(self.descriptor && self.descriptor.insertSelector && [self.object respondsToSelector:self.descriptor.insertSelector]){
            [self.object willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
            [self.object performSelector:self.descriptor.insertSelector withObject:objects withObject:indexes];
            [self.object didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:self.keyPath];
        }
        else{
            id proxy= nil;
            if(self.subKeyPath != nil) {
                proxy = [self.subObject mutableArrayValueForKey:self.subKeyPath];
            }
            else{
                proxy = self.subObject;
            }
            [proxy insertObjects:objects atIndexes:indexes];
        }
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes{
	Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKCollection class]]){
		[[self value]removeObjectsAtIndexes:indexes];
        return;
    }
	CKAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
	
	if(self.descriptor && self.descriptor.removeSelector && [self.object respondsToSelector:self.descriptor.removeSelector]){
		[self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
		[self.object performSelector:self.descriptor.removeSelector withObject:indexes];
		[self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:self.keyPath];
	}
	else{
        id proxy= nil;
        if(self.subKeyPath != nil) {
            proxy = [self.subObject mutableArrayValueForKey:self.subKeyPath];
        }
        else{
            proxy = self.subObject;
        }
		[proxy removeObjectsAtIndexes:indexes];
	}
}

- (void)removeAllObjects{
	Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKCollection class]]){
        [[self value]removeAllObjects];
        return;
    }
	CKAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
	
	NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[[self value] count])];
	    
	if(self.descriptor && self.descriptor.removeAllSelector && [self.object respondsToSelector:self.descriptor.removeAllSelector]){
        [self.object willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
		[self.object performSelector:self.descriptor.removeAllSelector];
        [self.object didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexSet forKey:self.keyPath];
	}
	else{
        NSMutableArray* proxy= nil;
        if(self.subKeyPath != nil) {
            proxy = [self.subObject mutableArrayValueForKey:self.subKeyPath];
        }
        else{
            proxy = self.subObject;
        }
		[proxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [proxy count])]];
	}
}

- (void)removeObject:(id)value{
    Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKCollection class]]){
        [[self value]removeObject:value];
        return;
    }
    CKAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[[self value] count])];
    
   
    NSMutableArray* proxy= nil;
    if(self.subKeyPath != nil) {
        proxy = [self.subObject mutableArrayValueForKey:self.subKeyPath];
    }
    else{
        proxy = self.subObject;
    }
    NSInteger index = [proxy indexOfObject:value];
    [proxy removeObjectAtIndex:index];
}

- (void)addObject:(id)value{
    Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKCollection class]]){
        [[self value]addObject:value];
        return;
    }
    CKAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,[[self value] count])];
    
    
    NSMutableArray* proxy= nil;
    if(self.subKeyPath != nil) {
        proxy = [self.subObject mutableArrayValueForKey:self.subKeyPath];
    }
    else{
        proxy = self.subObject;
    }
    [proxy addObject:value];
}

- (BOOL)isContainer{
    Class selfClass = [self type];
    return [NSObject isClass:selfClass kindOfClass:[CKCollection class]] || [NSObject isClass:selfClass kindOfClass:[NSArray class]];
}

- (BOOL)containsObject:(id)value{
    Class selfClass = [self type];
    if([NSObject isClass:selfClass kindOfClass:[CKCollection class]]){
        return [[[self value]allObjects]containsObject:value];
    }
    
    CKAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]],@"invalid property type");
    return [[self value]containsObject:value];
}

- (NSInteger)count{
	Class selfClass = [self type];
	CKAssert([NSObject isClass:selfClass kindOfClass:[NSArray class]]
             ||[NSObject isClass:selfClass kindOfClass:[CKCollection class]],@"invalid property type");
    return [[self value]count];
}

- (id) copyWithZone:(NSZone *)zone {
    return [[CKProperty alloc]initWithObject:self.object keyPath:self.keyPath weak:self.weak];
}

- (BOOL)isEqual:(id)object{
    if([object isKindOfClass:[CKProperty class]]){
        CKProperty* other = (CKProperty*)object;
        BOOL bo = (other.subObject == self.subObject) && [other.subKeyPath isEqualToString:self.subKeyPath];
        return bo;
    }
    return NO;
}

- (NSUInteger)hash{
    if(!self.hashValue){
        self.hashValue = [NSString stringWithFormat:@"<%p>_%@",self.subObject,self.subKeyPath];
    }
    return [self.hashValue hash];
}


- (BOOL)isNumber{
    switch(self.descriptor.propertyType){
        case CKClassPropertyDescriptorTypeChar:
        case CKClassPropertyDescriptorTypeCppBool:
        case CKClassPropertyDescriptorTypeInt:
        case CKClassPropertyDescriptorTypeShort:
        case CKClassPropertyDescriptorTypeLong:
        case CKClassPropertyDescriptorTypeLongLong:
        case CKClassPropertyDescriptorTypeUnsignedChar:
        case CKClassPropertyDescriptorTypeUnsignedInt:
        case CKClassPropertyDescriptorTypeUnsignedShort:
        case CKClassPropertyDescriptorTypeUnsignedLong:
        case CKClassPropertyDescriptorTypeUnsignedLongLong:
        case CKClassPropertyDescriptorTypeFloat:
        case CKClassPropertyDescriptorTypeDouble:
            return YES;
    }
    return [NSObject isClass:self.descriptor.type exactKindOfClass:[NSNumber class]];
}

- (BOOL)isFloatingNumber{
    switch(self.descriptor.propertyType){
        case CKClassPropertyDescriptorTypeFloat:
        case CKClassPropertyDescriptorTypeDouble:
            return YES;
    }
    
    if ([NSObject isClass:self.descriptor.type exactKindOfClass:[NSNumber class]] ){
        NSNumber* number = [self value];
        if(!number)
            return NO;
        
        return strcmp( @encode(float), [number objCType] ) == 0 || strcmp( @encode(double), [number objCType] ) == 0;
    }
    
    return NO;
}


- (BOOL)isBool{
    switch(self.descriptor.propertyType){
        case CKClassPropertyDescriptorTypeChar:
        case CKClassPropertyDescriptorTypeCppBool:
            return YES;
    }
    return NO;
}

@end
