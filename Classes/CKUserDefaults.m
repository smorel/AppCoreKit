//
//  CKUserDefaults.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-15.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUserDefaults.h"
#import "CKNSObject+CKRuntime.h"

@interface CKUserDefaults()
- (void)initFromPlist;
- (void)initFromUserDefaults;
@end

@implementation CKUserDefaults

- (void)observeAllProperties{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
            [self addObserver:self forKeyPath:property.name options: (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:self];
        }
	}
}

- (void)unobserveAllProperties{
	NSArray* allProperties = [self allPropertyDescriptors];
	for(CKClassPropertyDescriptor* property in allProperties){
		if(property.isReadOnly == NO){
            [self removeObserver:self forKeyPath:property.name];
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
                    [self setValue:value forKeyPath:property.name];
                }
            }
        }
    }
}

- (void)initFromUserDefaults{
    NSArray* allProperties = [self allPropertyDescriptors];
    for(CKClassPropertyDescriptor* property in allProperties){
        if(property.isReadOnly == NO){
            NSString* key = [NSString stringWithFormat:@"%@_%@",[[self class]description],property.name];
            id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            if(value != nil){
                [self setValue:value forKeyPath:property.name];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)theKeyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	[super observeValueForKeyPath:theKeyPath ofObject:object change:change context:context];
    
    NSString* key = [NSString stringWithFormat:@"%@_%@",[[self class]description],theKeyPath];
    id value = [self valueForKeyPath:theKeyPath];
    if(value != nil){
        [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    }
    else{
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}


@end
