//
//  NSString+Size.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-03.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKStringHelper : NSObject

+ (CGSize)sizeForText:(NSString*)text font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
+ (CGSize)sizeForAttributedText:(NSAttributedString*)text constrainedToSize:(CGSize)size;

@end
