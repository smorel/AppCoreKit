//
//  CKCollectionViewGridLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewLayout.h"

/**
     CKCollectionViewGridLayout* gridLayout  = [[CKCollectionViewGridLayout alloc]init];
     gridLayout.pages = @[
          @[ @(1) ], @[ @(.3), @(.7) ], @[ @(.7), @(.3)], //page %0
          @[ @[ @(1) ], @[ @(.3), @(.2), @(.5) ], @[ @(.2),@(.3),@(.2), @(.3)] ] //page %1
          @[ @(.5), @(.5) ], @[ @(.5), @(.5) ], @[ @(.5), @(.5) ], @[ @(.5), @(.5) ] //page %3
     ];
 */


@interface CKCollectionViewGridLayout : CKCollectionViewLayout

/**  array of pages
        Page : array of rows
        Row  : float representing the % occupation of items
 */
@property(nonatomic,retain) NSArray* pages;

/**
 */
@property(nonatomic,assign) NSInteger horizontalSpace;

/**
 */
@property(nonatomic,assign) NSInteger verticalSpace;

/**
 */
@property(nonatomic,assign) CKCollectionViewLayoutOrientation orientation;

/**
 */
@property(nonatomic,assign) BOOL pagingEnabled;

@end
