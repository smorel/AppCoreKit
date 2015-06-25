//
//  CKStringHelper.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-03.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKStringHelper.h"
#import "CKVersion.h"

@implementation CKStringHelper 

+ (CGSize)sizeForText:(NSString*)text font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode{
    if(!text || !font){
        return CGSizeMake(0,0);
    }
    
    if([CKOSVersion() floatValue] >= 7){
        NSAttributedString *attributedText = [[[NSAttributedString alloc] initWithString:text attributes:@{ @"NSFont" /*NSFontAttributeName*/ : font }]autorelease];
        return [self sizeForAttributedText:attributedText constrainedToSize:size];
    }
    return [text sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
}

+ (CGSize)sizeForAttributedText:(NSAttributedString*)attributedText constrainedToSize:(CGSize)size{
    if(!attributedText){
        return CGSizeMake(0,0);
    }
    
    CGRect rect = [attributedText boundingRectWithSize:size
                                               options:(1 << 0) //NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    
    CGFloat floorWidth  = (CGFloat)(floor(rect.size.width));
    CGFloat floorHeight = (CGFloat)(floor(rect.size.height));

    return CGSizeMake(floorWidth + ((floorWidth == rect.size.width) ? 0 : 1),floorHeight + ((floorHeight == rect.size.height) ? 0 : 1));
}

@end
