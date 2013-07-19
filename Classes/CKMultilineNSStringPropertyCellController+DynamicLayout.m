//
//  CKMultilineNSStringPropertyCellController+DynamicLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKMultilineNSStringPropertyCellController+DynamicLayout.h"
#import "CKTableViewCellController+DynamicLayout_Private.h"
#import "CKMultilineNSStringPropertyCellController.h"
#import "CKTableViewCellController+DynamicLayout.h"
#import "CKProperty.h"
#import "NSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "CKTableCollectionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Positioning.h"
#import "CKDebug.h"
#import "NSValueTransformer+Additions.h"

#define TEXTVIEWINSETS 8

@implementation CKMultilineNSStringPropertyCellController(CKDynamicLayout)

- (CGRect)value3TextViewFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textViewText:(NSString*)textViewText textViewStyle:(NSDictionary*)textViewStyle image:(UIImage*)image{
    
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = (text == nil) ? realWidth : (realWidth * self.componentsRatio);
    
    CGFloat textFieldWidth = width - (self.contentInsets.right + ((text == nil) ? self.contentInsets.left : self.horizontalSpace));
    CGFloat textFieldX = self.contentInsets.left + (realWidth - (self.contentInsets.right + self.contentInsets.left) - textFieldWidth);
    
    CGSize textViewTextSize = [self sizeForText:textViewText withStyle:textViewStyle constraintToWidth:textFieldWidth];
    
    UIFont* font = [textViewStyle objectForKey:CKDynamicLayoutFont];
    textViewTextSize.height += 2 * TEXTVIEWINSETS;
    
    CGFloat textFieldY = self.contentInsets.top - TEXTVIEWINSETS;
    return CGRectMake(textFieldX - TEXTVIEWINSETS,textFieldY,textFieldWidth + 2*TEXTVIEWINSETS,MAX(textViewTextSize.height,font.lineHeight + 2 * TEXTVIEWINSETS));
}

- (CGRect)subtitleTextViewFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textViewText:(NSString*)textViewText textViewStyle:(NSDictionary*)textViewStyle  image:(UIImage*)image{
    CGRect textFrame = [self subtitleTextFrameUsingText:text textStyle:textStyle detailText:textViewText detailTextStyle:textViewStyle image:image];
    CGFloat width = [self contentViewWidth] - (image.size.width + self.horizontalSpace + self.contentInsets.left + self.contentInsets.right);
    
    CGSize textViewTextSize = [self sizeForText:textViewText withStyle:textViewStyle constraintToWidth:width];
    textViewTextSize.height += 2 * TEXTVIEWINSETS;
    
    UIFont* font = [textViewStyle objectForKey:CKDynamicLayoutFont];
    
    CGRect textViewFrame = CGRectMake(MAX(self.contentInsets.left,textFrame.origin.x) - TEXTVIEWINSETS,
                                      MAX(self.contentInsets.top,text ? (textFrame.origin.y + textFrame.size.height + self.verticalSpace) : 0),
                                      width + 2 * TEXTVIEWINSETS,
                                      MAX(textViewTextSize.height,font.lineHeight));
    return textViewFrame;
}

- (CGRect)propertyGridTextViewFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textViewText:(NSString*)textViewText textViewStyle:(NSDictionary*)textViewStyle image:(UIImage*)image{
    
    //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        return [self value3TextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:image];
    //}
    
    //return [self subtitleTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:image];
}


- (NSDictionary*)textViewStyle{
    NSMutableDictionary* defaultStyle = [NSMutableDictionary dictionary];
    [defaultStyle setObject:[NSNumber numberWithInt:0] forKey:CKDynamicLayoutNumberOfLines];
    [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
    
    //TODO : Verify lineBreakMode for textView !
    [defaultStyle setObject:[NSNumber numberWithInt:UILineBreakModeWordWrap] forKey:CKDynamicLayoutLineBreakMode];
    
    if(self.cellStyle == CKTableViewCellStyleIPadForm){
        [defaultStyle setObject:[UIFont systemFontOfSize:17] forKey:CKDynamicLayoutFont];
    }
    else if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
        //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            [defaultStyle setObject:[UIFont systemFontOfSize:17] forKey:CKDynamicLayoutFont];
        //}
        //else{
        //    [defaultStyle setObject:[UIFont systemFontOfSize:17] forKey:CKDynamicLayoutFont];
        //}
    }
    else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
        [defaultStyle setObject:[UIFont systemFontOfSize:14] forKey:CKDynamicLayoutFont];
    }
    
    return [self styleForViewWithKeyPath:@"textView" defaultStyle:defaultStyle];
}

- (CGSize)computeSize{
    NSString* text = self.text;
    CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad
       || self.cellStyle == CKTableViewCellStyleIPadForm
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        text = _(descriptor.name);
    }
    
    NSString* result = [NSValueTransformer transformProperty:[self objectProperty] toClass:[NSString class]];
    CGSize size = [self computeSizeUsingText:text detailText:result image:self.image];
    self.invalidatedSize = NO;
    
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    if(!readonly){
        if(self.cellStyle == CKTableViewCellStyleIPadForm
           || self.cellStyle == CKTableViewCellStyleIPhoneForm
           || self.cellStyle == CKTableViewCellStyleSubtitle2){
            
            NSDictionary* textViewStyle = [self textViewStyle];
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSString* textViewText = [NSString stringWithFormat:@"%@a",result]; 
            //we append 'a' here to manage extra return spaces in text not taken in account when computing text size.
            
            CGFloat height = 0;
            if(self.cellStyle == CKTableViewCellStyleIPadForm){
                CGRect frame = [self value3TextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
                height = MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom);
            }
            else if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
                CGRect frame = [self propertyGridTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
                height = MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom);
            }
            else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                CGRect frame = [self subtitleTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
                height = frame.origin.y + frame.size.height + self.contentInsets.bottom;
            }    
            
            return CGSizeMake(320,height);
        }else{
            CKAssert(NO,@"only CKTableViewCellStyleIPadForm, CKTableViewCellStyleIPhoneForm, CKTableViewCellStyleSubtitle2 are supported for CKMultilineNSStringPropertyCellController");
        }
    }
    return size;
}

- (void)performLayout{
    [super performLayout];
    
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    if(!readonly){
        if(self.cellStyle == CKTableViewCellStyleIPadForm
           || self.cellStyle == CKTableViewCellStyleIPhoneForm
           || self.cellStyle == CKTableViewCellStyleSubtitle2){
            
            NSDictionary* textViewStyle = [self textViewStyle];
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSString* text = self.text;
            CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad
               || self.cellStyle == CKTableViewCellStyleIPadForm){
                text = _(descriptor.name);
            }
            
            NSString* result = [NSValueTransformer transformProperty:[self objectProperty] toClass:[NSString class]];
            NSString* textViewText = [NSString stringWithFormat:@"%@a",result]; 
            //we append 'a' here to manage extra return spaces in text not taken in account when computing text size.
            
            UITableViewCell* cell = self.tableViewCell;
            CKTextView* textView = (CKTextView*)[cell viewWithTag:50000];
            
            if(self.cellStyle == CKTableViewCellStyleIPadForm){
                textView.frame = [self value3TextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
            }
            else if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
                textView.frame = [self propertyGridTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
            }
            else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                textView.frame = [self subtitleTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
            }
        }else{
            CKAssert(NO,@"only CKTableViewCellStyleIPadForm, CKTableViewCellStyleIPhoneForm, CKTableViewCellStyleSubtitle2 are supported for CKMultilineNSStringPropertyCellController");
        }
    }
}

@end