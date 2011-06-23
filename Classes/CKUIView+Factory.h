//
//  CKUIView+Factory.h
//  CloudKit
//
//  Created by Jean-Philippe Martin on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (CKUIViewFactory)

+ (UIView *)titleViewForTitle:(NSString *)title withSubtitle:(NSString *)subtitle;

@end
