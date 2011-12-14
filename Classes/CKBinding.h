//
//  CKBinding.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "CKNSObject+Bindings.h"

/** TODO
 */
@interface CKBinding : NSObject{
    id _context;
    CKBindingsContextOptions _contextOptions;
}

@property(nonatomic,assign) id context;
@property(nonatomic,assign) CKBindingsContextOptions contextOptions;

- (void)bind;
- (void)unbind;
- (void)reset;

@end
