//
//  CKColorPalette.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-18.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

@interface CKColorPalette : CKCascadingTree

+ (NSDictionary*)colorPaletteWithKey:(NSString*)key;

/** PaletteKey.ColorKey
 */
+ (UIColor*)colorWithKeyPath:(NSString*)keyPath;

@end
