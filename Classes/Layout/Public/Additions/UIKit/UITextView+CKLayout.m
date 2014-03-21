//
//  UITextView+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "UITextView+CKLayout.h"
#import <objc/runtime.h>
#import "UIView+CKLayout.h"
#import "CKVerticalBoxLayout.h"
#import "CKRuntime.h"
#import "CKStringHelper.h"
#import "CKVersion.h"

@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@interface UITextView (CKLayout_Private)
@property(nonatomic,assign) BOOL registeredOnTextNotification;
@end

static char UITextViewRegisteredOnTextNotificationKey;


@implementation UITextView (CKLayout_Private)
@dynamic registeredOnTextNotification;

- (void)setRegisteredOnTextNotification:(BOOL)registeredOnTextNotification{
    objc_setAssociatedObject(self, &UITextViewRegisteredOnTextNotificationKey, [NSNumber numberWithBool:registeredOnTextNotification], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)registeredOnTextNotification{
    id value = objc_getAssociatedObject(self, &UITextViewRegisteredOnTextNotificationKey);
    return value ? [value boolValue] : NO;
}

@end




static char UITextViewUsesAttributedStringKey;

@implementation UITextView (CKLayout)

- (void)UITextView_Layout_dealloc{
    if([self registeredOnTextNotification]){
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    }
    [self UITextView_Layout_dealloc];
}

- (void)UITextView_Layout_setContentOffset:(CGPoint)offset{
    //Adjusts content offset when layout system sets the frame of the UITextView.
    if(self.bounds.size.height >= self.contentSize.height){
        offset.y = 0;
    }
    if(self.bounds.size.width >= self.contentSize.width){
        offset.x = 0;
    }
    
    [self UITextView_Layout_setContentOffset:offset];
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(![self registeredOnTextNotification]){
        [[NSNotificationCenter defaultCenter]addObserverForName:UITextViewTextDidChangeNotification object:self queue:nil usingBlock:^(NSNotification *note) {
            [(UITextView*)note.object invalidateLayout];
        }];
        [self setRegisteredOnTextNotification:YES];
    }
    
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    
    /*if(   self.lastPreferedSize.width > 0
       && self.lastPreferedSize.height > 0
       && size.width >= self.lastComputedSize.width
       && size.height >= self.lastComputedSize.height
       && self.lastPreferedSize.width <= self.lastComputedSize.width
       && self.lastPreferedSize.height <= self.lastComputedSize.height){
        return self.lastPreferedSize;
    }
    */
    self.lastComputedSize = size;
    
    size.width -= self.padding.left + self.padding.right;
    size.height -= self.padding.top + self.padding.bottom;
    
    CGFloat theWidth = (self.maximumSize.width != MAXFLOAT) ? MIN(self.maximumSize.width,size.width) : size.width;
    theWidth = (self.minimumSize.width != -MAXFLOAT) ? MAX(self.minimumSize.width,theWidth) : theWidth;
    
    CGSize maxSize = CGSizeMake(theWidth, MAXFLOAT);
    
    CGSize ret = CGSizeZero;
    if(![self usesAttributedString] && self.text){
        NSMutableString* str = [NSMutableString stringWithString:self.text];
        //If ends by new line, adds an extra character for sizeWithFont to take this new line into account.
        if([str length] > 0 && [str characterAtIndex:[str length] -1] == '\n'){
            [str appendString:@"a"];
        }
        ret = [CKStringHelper sizeForText:str font:self.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    }else if([CKOSVersion() floatValue] >= 6){
        if(self.attributedText){
            ret = [CKStringHelper sizeForAttributedText:self.attributedText constrainedToSize:maxSize];
        }
    }
    
    if([self.containerLayoutBox isKindOfClass:[CKVerticalBoxLayout class]])
        ret.width = size.width;
    
    //If contentSize not initalized correctly, compute the size using the text and the font instead. (first initialization !)
    if(self.contentSize.width < size.width){
        ret.height =  MAX(ret.height+16,self.font.lineHeight + 16);
    }else{
        ret.height = MAX(self.contentSize.height,self.font.lineHeight + 16);
    }
    
    ret = [CKLayoutBox preferredSizeConstraintToSize:ret forBox:self];
    
    CGFloat width = MAX(size.width,ret.width) + self.padding.left + self.padding.right;
    CGFloat height = ret.height + self.padding.top + self.padding.bottom;
    self.lastPreferedSize = CGSizeMake(width,height);
    return self.lastPreferedSize;
}

- (void)UITextView_Layout_setText:(NSString*)text{
    if(![text isEqualToString:self.text]){
        [self setUsesAttributedString:NO];
        [self UITextView_Layout_setText:text];
        [self invalidateLayout];
    }
}

- (void)UITextView_Layout_setFont:(UIFont*)font{
    if(![font isEqual:self.font]){
        [self UITextView_Layout_setFont:font];
        [self invalidateLayout];
    }
}
- (void)UITextView_Layout_setAttributedText:(NSAttributedString*)attributedText{
    if(![attributedText isEqualToAttributedString:self.attributedText]){
        [self setUsesAttributedString:YES];
        
        [self UITextView_Layout_setAttributedText:attributedText];
        
        [self invalidateLayout];
    }
}
- (void)setUsesAttributedString:(BOOL)bo{
    objc_setAssociatedObject(self,
                             &UITextViewUsesAttributedStringKey,
                             [NSNumber numberWithBool:bo],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)usesAttributedString{
    id value = objc_getAssociatedObject(self, &UITextViewUsesAttributedStringKey);
    return value ? [value boolValue] : NO;
}

+ (void)load{
    CKSwizzleSelector([UITextView class], @selector(setText:), @selector(UITextView_Layout_setText:));
    if([CKOSVersion() floatValue] >= 6){
        CKSwizzleSelector([UITextView class], @selector(setAttributedText:), @selector(UITextView_Layout_setAttributedText:));
    }
    CKSwizzleSelector([UITextView class], @selector(setFont:), @selector(UITextView_Layout_setFont:));
    CKSwizzleSelector([UITextView class], @selector(setContentOffset:), @selector(UITextView_Layout_setContentOffset:));
    CKSwizzleSelector([UITextView class], @selector(dealloc),  @selector(UITextView_Layout_dealloc));
}

@end

