//
//  CKUINavigationControllerAdditions.h
//  CloudKit
//
//  Created by Olivier Collet on 10-02-04.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UINavigationController (CKUINavigationControllerAdditions)
- (NSDictionary *)getStyles;
- (void)setStyles:(NSDictionary *)styles animated:(BOOL)animated;
@end
