//
//  CKObject+CKSingleton.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-13.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CKSingleton)

+ (id)newSharedInstance;
+ (id)sharedInstance;

@end
