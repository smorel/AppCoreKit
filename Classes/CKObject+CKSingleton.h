//
//  CKObject+CKSingleton.h
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-13.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKObject.h"

@interface CKObject (CKSingleton)

+ (id)sharedInstance;

@end