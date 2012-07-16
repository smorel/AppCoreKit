//
//  CKNSError+Additions.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>


NSError* aggregateError(NSError* error,NSString* domain,NSInteger code,NSString* str);