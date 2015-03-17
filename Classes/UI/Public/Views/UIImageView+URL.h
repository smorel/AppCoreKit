//
//  UIImageView+URL.h
//  MightyCast-iOS.sample
//
//  Created by Sebastien Morel on 4/2/2014.
//  Copyright (c) 2014 MightyCast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (URL)

- (void)loadImageWithUrl:(NSURL*)url completion:(void(^)(UIImage* image,NSError* error))completion;
- (void)cancelNetworkOperations;

@end
