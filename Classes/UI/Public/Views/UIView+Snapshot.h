//
//  UIView+Snapshot.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/28/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UIView(Snaphot)

/**
 */
- (UIImage*)snapshot;
- (UIImage*)snapshotWithoutSubviews;

/** snapshoting without subviews is to grab a snapshot of the view without subviews.
 But sometime some subviews are the views that display the content of the view for example CKImageView.
 */
- (NSArray*)viewsToIncludeInSnapshotWithoutSubviews;

@end

/**
 */
@interface UIScrollView(Snaphot)

/**
 */
- (UIImage*)snapshot;

@end


/**
 */
@interface UIScreen(Snaphot)

/** 
 */
- (UIImage*)snapshot;

@end