//
//  CKLayoutManager.h
//  CloudKit
//
//  Created by Guillaume Campagna on 12-06-06.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CKLayoutView;
@protocol CKLayoutManager <NSObject>

@required
@property (nonatomic, assign) CKLayoutView *layoutView;
@property (nonatomic, assign) UIEdgeInsets inset;
- (void)layout;

@optional
@property (nonatomic, readonly) CGSize preferedSize;
@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize maximumSize;

@end
