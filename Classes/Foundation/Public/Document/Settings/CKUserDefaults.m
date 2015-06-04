//
//  CKUserDefaults.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUserDefaults.h"
#import "NSObject+Runtime.h"
#import "CKCollection.h"
#import "CKDebug.h"
#import "NSValueTransformer+Additions.h"

@interface CKUserDefaults()
- (void)initFromPlist;
- (void)initFromUserDefaults;
@end

@implementation CKUserDefaults

- (void)observeAllProperties{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
            CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
            if(attributes.serializable == YES){
                if([NSObject isClass:property.type kindOfClass:[CKCollection class]]){
                    CKCollection* collection = [self valueForKey:property.name];
                    [collection addObserver:self];
                }else{
                    [self addObserver:self forKeyPath:property.name options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:self];
                }
            }
        }
	}
}

- (void)unobserveAllProperties{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
            CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
            if(attributes.serializable == YES){
                if([NSObject isClass:property.type kindOfClass:[CKCollection class]]){
                    CKCollection* collection = [self valueForKey:property.name];
                    [collection removeObserver:self];
                }
                else{
                    [self removeObserver:self forKeyPath:property.name];
                }
            }
		}
	}
}

- (void)initializeKVO{/*BYPASS*/}
- (void)uninitializeKVO{/*BYPASS*/}

- (id)init{
    self = [super init];
    [self initFromPlist];
    [self initFromUserDefaults];
	[self observeAllProperties];
    return self;
}

- (void)dealloc{
	[self unobserveAllProperties];
	[super dealloc];
}


- (void)initFromPlist{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[[self class]description] ofType:@"plist"];
    if([filePath length] > 0 && [filePath isKindOfClass:[NSNull class]] == NO){
        NSMutableDictionary* params = [[[NSMutableDictionary alloc] initWithContentsOfFile:filePath]autorelease];
        NSArray* allProperties = [self allPropertyDescriptors];
        for(CKClassPropertyDescriptor* property in allProperties){
            if(property.isReadOnly == NO){
                NSString* key = [NSString stringWithFormat:@"%@",property.name];
                id value = [params objectForKey:key];
                if(value != nil){
                    if([NSObject isClass:property.type kindOfClass:[CKCollection class]]){
                        CKCollection* collection = [self valueForKey:property.name];
                        NSMutableArray* arrayToSerialize = [NSMutableArray array];
                        for(id object in value){
                            if(![object isKindOfClass:[NSString class]]){
                                CKAssert(NO,@"We only support collection of NSString in CKUserDefaults");
                            }else{
                                [arrayToSerialize addObject:object];
                            }
                        }
                        [collection addObjectsFromArray:arrayToSerialize];
                    }
                    else{
                        [NSValueTransformer transform:value inProperty:[CKProperty propertyWithObject:self keyPath:property.name]];
                        //                        [self setValue:value forKeyPath:property.name];
                    }
                }
            }
        }
    }
}

- (void)initFromUserDefaults{
    NSArray* allProperties = [self allPropertyDescriptors];
    for(CKClassPropertyDescriptor* property in allProperties){
        if(property.isReadOnly == NO){
            CKPropertyExtendedAttributes* attributes = [property extendedAttributesForInstance:self];
            if(attributes.serializable == YES){
                NSString* key = [NSString stringWithFormat:@"%@_%@",[[self class]description],property.name];
                id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
                if(value != nil){
                    if([NSObject isClass:property.type kindOfClass:[CKCollection class]]){
                        CKCollection* collection = [self valueForKey:property.name];
                        [collection addObjectsFromArray:value];
                    }
                    else{
                        [NSValueTransformer transform:value inProperty:[CKProperty propertyWithObject:self keyPath:property.name]];
                        //[self setValue:value forKeyPath:property.name];
                    }
                }
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	[super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    
    if([object isKindOfClass:[CKCollection class]]){
        NSString* key = nil;
        for(NSString* pName in [self allPropertyNames]){
            id p = [self valueForKey:pName];
            if(p == object){
                key = [NSString stringWithFormat:@"%@_%@",[[self class]description],pName];
                break;
            }
        }
        
        NSMutableArray* arrayToSerialize = [NSMutableArray array];
        NSArray* ar = [object allObjects];
        for(id object in ar){
            if(![object isKindOfClass:[NSString class]]){
                CKAssert(NO,@"We only support collection of NSString in CKUserDefaults");
            }else{
                [arrayToSerialize addObject:object];
            }
        }
        [[NSUserDefaults standardUserDefaults]setObject:arrayToSerialize forKey:key];
    }else{
        NSString* key = [NSString stringWithFormat:@"%@_%@",[[self class]description],theKeyPath];
        id value = [self valueForKeyPath:theKeyPath];
        if(value != nil){
            NSString* str = [NSValueTransformer transformProperty:[CKProperty propertyWithObject:self keyPath:theKeyPath] toClass:[NSString class]];
            [[NSUserDefaults standardUserDefaults]setObject:str forKey:key];
        }
        else{
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}


@end
