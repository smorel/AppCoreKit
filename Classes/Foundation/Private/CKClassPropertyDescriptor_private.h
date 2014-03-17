//
//  CKClassPropertyDescriptor_private.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//


#import "CKClassPropertyDescriptor.h"



#ifdef __cplusplus
extern "C" {
#endif
    
typedef struct CKStructParsedAttributes{
	NSString* className;
	NSString* encoding;
	NSString* structFormat;
	NSInteger size;
    BOOL pointer;
}CKStructParsedAttributes;

CKStructParsedAttributes parseStructAttributes(NSString* attributes);
    
#ifdef __cplusplus
}
#endif



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
