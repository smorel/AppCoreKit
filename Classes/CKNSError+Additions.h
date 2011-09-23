//
//  CKNSError+Additions.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-23.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


NSError* aggregateError(NSError* error,NSString* domain,NSInteger code,NSString* str);