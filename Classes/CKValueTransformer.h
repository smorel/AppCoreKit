//
//  CKObjectTransformer.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-22.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/** TODO
 */
@interface CKValueTransformer : NSObject {

}

+ (id)transformValue:(id)value toClass:(Class)type;

@end
