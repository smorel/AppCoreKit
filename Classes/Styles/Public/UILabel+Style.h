//
//  UILabel+Style.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Style.h"


/**
 */
@interface UILabel (CKStyle)

/**
 */
@property (nonatomic) NSString *fontName;
/**
 */
@property (nonatomic) CGFloat fontSize;

@end


/**
 */
@interface UITextField (CKStyle)

/**
 */
@property (nonatomic) NSString *fontName;
/**
 */
@property (nonatomic) CGFloat fontSize;

@end