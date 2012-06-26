//
//  CKClassPropertyDescriptor_private.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-06-26.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//


#import "CKClassPropertyDescriptor.h"

/**
 */
@interface CKClassPropertyDescriptorManager : NSObject

+ (CKClassPropertyDescriptorManager*)defaultManager;

- (NSArray*)allPropertiesForClass:(Class)type;
- (NSArray*)allViewsPropertyForClass:(Class)type;
- (NSArray*)allPropertieNamesForClass:(Class)type;
- (CKClassPropertyDescriptor*)property:(NSString*)name forClass:(Class)type;
- (void)addPropertyDescriptor:(CKClassPropertyDescriptor*)descriptor forClass:(Class)c;

@end
