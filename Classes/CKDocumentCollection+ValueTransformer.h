//
//  CKDocumentArray+ValueTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKDocumentCollection.h"


/** TODO
 */
@interface CKDocumentCollection (CKValueTransformer)

+ (CKDocumentCollection*)convertFromNSArray:(NSArray*)array withContentClassName:(NSString*)className;
+ (id)convertFromNSArray:(NSArray*)array;

@end