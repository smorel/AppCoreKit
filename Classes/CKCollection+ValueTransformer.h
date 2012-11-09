//
//  CKCollection+ValueTransformer.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKCollection.h"


/**
 */
@interface CKCollection (CKValueTransformer)

/**
 */
+ (CKCollection*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className;

/**
 */
+ (id)convertFromNSArray:(NSArray*)array;

@end