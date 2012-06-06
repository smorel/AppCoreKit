//
//  UIView+LayoutHelper.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LayoutHelper)

@property (nonatomic, readonly) CGSize preferedSize;
@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize maximumSize;

@end
