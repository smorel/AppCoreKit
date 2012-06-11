//
//  CKGridLayout.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKLayoutManager.h"
#import <UIKit/UIKit.h>

@interface CKGridLayout : NSObject <CKLayoutManager>

////Layout Manager
@property (nonatomic, assign) id<CKLayoutContainer> layoutContainer;
@property (nonatomic, assign) UIEdgeInsets inset;
- (void)layout;

@property (nonatomic, readonly) CGSize preferedSize;
@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize maximumSize;

////Grid
@property (nonatomic, assign) CGSize gridSize;
@property (nonatomic, assign) CGFloat minMarginSize;

+ (CKGridLayout*)horizontalGridLayout;
+ (CKGridLayout*)verticalGridLayout;
+ (CKGridLayout*)gridLayoutWithGridSize:(CGSize)aGridSize;

@end
