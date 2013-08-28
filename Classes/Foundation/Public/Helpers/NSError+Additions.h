//
//  NSError+Additions.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    /**
     */
    NSError* aggregateError(NSError* error,NSString* domain,NSInteger code,NSString* str);
    
#ifdef __cplusplus
}
#endif