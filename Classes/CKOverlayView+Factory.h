//
//  CKOverlayView+Factory.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKOverlayView.h"


/** TODO
 */
@interface CKOverlayView (CKOverlayViewFactory)

+ (id)overlayViewWithView:(UIView *)view text:(NSString *)text;
+ (id)loadingOverlayWithText:(NSString *)text;
+ (id)overlayViewWithImage:(UIImage *)image text:(NSString *)text;

@end
