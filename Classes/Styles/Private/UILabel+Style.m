//
//  UILabel+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "UILabel+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKLocalization.h"

@implementation UILabel (CKStyle)

- (void)setFontName:(NSString *)fontName{
    CGFloat fontSize = self.font.pointSize;
    [self setFont:[UIFont fontWithName:fontName size:fontSize]];
}

- (NSString*)fontName{
    return self.font.fontName;
}

- (void)setFontSize:(CGFloat)fontSize{
    NSString* fontName = self.font.fontName;
    [self setFont:[UIFont fontWithName:fontName size:fontSize]];
}

- (CGFloat)fontSize{
    return self.font.pointSize;
}


@end

@implementation UITextField (CKStyle)

- (void)setFontName:(NSString *)fontName{
    CGFloat fontSize = self.font.pointSize;
    [self setFont:[UIFont fontWithName:fontName size:fontSize]];
}

- (NSString*)fontName{
    return self.font.fontName;
}

- (void)setFontSize:(CGFloat)fontSize{
    NSString* fontName = self.font.fontName;
    [self setFont:[UIFont fontWithName:fontName size:fontSize]];
}

- (CGFloat)fontSize{
    return self.font.pointSize;
}

@end
