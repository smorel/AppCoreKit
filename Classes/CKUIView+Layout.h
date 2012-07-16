//
//  CKUIView+Layout.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@interface UIView (CKUIViewLayoutAdditions)

- (void)layoutSubviewsWithColumns:(NSUInteger)nbColumns lines:(NSUInteger)nbLines;

@end
