//
//  CKBinding.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@protocol CKBinding
- (void)bind;
- (void)unbind;
- (void)reset;
@end
