//
//  CKUIViewController+Style.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKUIView+Style.h"

/** TODO
 */
@interface UIViewController (CKStyle)

- (NSMutableDictionary*)controllerStyle;
- (NSMutableDictionary*)applyStyle;
- (NSMutableDictionary*)applyStyleWithParentStyle:(NSMutableDictionary*)style;

@end
