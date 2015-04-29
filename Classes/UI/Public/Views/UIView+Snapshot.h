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