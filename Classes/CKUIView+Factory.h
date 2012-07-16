//
//  CKUIView+Factory.h
//  CloudKit
//
//  Created by Jean-Philippe Martin.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@interface UIView (CKUIViewFactory)

+ (UIView *)titleViewForTitle:(NSString *)title withSubtitle:(NSString *)subtitle;

@end
