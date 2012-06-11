//
//  UIView+LayoutHelper.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LayoutHelper)

@property (nonatomic, assign) CGSize preferedSize;
@property (nonatomic, assign) CGSize minimumSize;
@property (nonatomic, assign) CGSize maximumSize;

@end
