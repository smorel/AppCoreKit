//
//  CKCollection+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKCollection.h"


/**
 */
@interface CKCollection (CKValueTransformer)

+ (CKCollection*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className;
+ (id)convertFromNSArray:(NSArray*)array;

@end