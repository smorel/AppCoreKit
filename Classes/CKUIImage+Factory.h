//
//  CKUIImage+Factory.h
//  CloudKit
//
//  Created by Olivier Collet on 10-07-23.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (Factory)

+ (UIImage *)imageStack:(NSInteger)nbImages size:(CGSize)size edgeInsets:(UIEdgeInsets)insets;

@end
