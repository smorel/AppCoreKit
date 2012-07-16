//
//  CKObjectTransformer.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/** TODO
 */
@interface CKValueTransformer : NSObject {}

+ (id)transformValue:(id)value toClass:(Class)type;

@end
