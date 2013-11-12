//
//  UIImage+FastLoading.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-08.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 */
@interface UIImage (FastLoading)

/**
 */
- (void) writeFastLoadingContentsToFile:(NSString *)outputPath;

/**
 */
+ (UIImage *)fastLoadingImageWithContentsOfFile:(NSString *)inputPath;

@end
