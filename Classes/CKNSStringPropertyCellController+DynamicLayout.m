//
//  CKNSStringPropertyCellController+DynamicLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKNSStringPropertyCellController+DynamicLayout.h"
#import "CKTableViewCellController+DynamicLayout_Private.h"
#import "CKNSStringPropertyCellController.h"
#import "CKTableViewCellController+DynamicLayout.h"
#import "CKProperty.h"
#import "NSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "NSValueTransformer+Additions.h"

#import "CKSheetController.h"
#import "UIView+Positioning.h"

#define TEXTFIELDINSETS 8

@implementation CKNSStringPropertyCellController(CKDynamicLayout)

- (CGRect)value3TextFieldFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textFieldText:(NSString*)textFieldText textFieldStyle:(NSDictionary*)textFieldStyle image:(UIImage*)image{
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = (text == nil) ? realWidth : (realWidth * self.componentsRatio);
    
    CGFloat textFieldWidth = width - (self.contentInsets.right + ((text == nil) ? self.contentInsets.left : self.componentsSpace));
    CGFloat textFieldX = self.contentInsets.left + (realWidth - (self.contentInsets.right + self.contentInsets.left) - textFieldWidth);
    
    CGSize textViewTextSize = [self sizeForText:textFieldText withStyle:textFieldStyle constraintToWidth:textFieldWidth];
    
    UIFont* font = [textFieldStyle objectForKey:CKDynamicLayoutFont];
    textViewTextSize.height += 2 * TEXTFIELDINSETS;
    
    CGFloat textFieldY = self.contentInsets.top - TEXTFIELDINSETS;
    return CGRectMake(textFieldX,textFieldY,textFieldWidth,MAX(textViewTextSize.height,font.lineHeight + 2 * TEXTFIELDINSETS));
}

- (CGRect)subtitleTextFieldFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textFieldText:(NSString*)textFieldText textFieldStyle:(NSDictionary*)textFieldStyle  image:(UIImage*)image{
    CGRect textFrame = [self subtitleTextFrameUsingText:text textStyle:textStyle detailText:textFieldText detailTextStyle:textFieldStyle image:image];
    CGFloat width = [self contentViewWidth] - (image.size.width + self.componentsSpace + self.contentInsets.left + self.contentInsets.right);

    CGSize textViewTextSize = [self sizeForText:textFieldText withStyle:textFieldStyle constraintToWidth:width];
    textViewTextSize.height += 2 * TEXTFIELDINSETS;
    
    UIFont* font = [textFieldStyle objectForKey:CKDynamicLayoutFont];
    CGRect textViewFrame = CGRectMake(MAX(self.contentInsets.left,textFrame.origin.x),
                                      MAX(self.contentInsets.top,text ? (textFrame.origin.y + textFrame.size.height + self.componentsSpace) : 0),
                                      width,
                                      MAX(textViewTextSize.height,font.lineHeight + 2 * TEXTFIELDINSETS));
    return textViewFrame;
}

- (NSDictionary*)textFieldStyle{
    NSMutableDictionary* defaultStyle = [NSMutableDictionary dictionary];
    [defaultStyle setObject:[NSNumber numberWithInt:1] forKey:CKDynamicLayoutNumberOfLines];
    [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
    [defaultStyle setObject:[UIFont systemFontOfSize:[UIFont systemFontSize]] forKey:CKDynamicLayoutFont];
    
    //TODO : Verify lineBreakMode for textField !
    [defaultStyle setObject:[NSNumber numberWithInt:UILineBreakModeWordWrap] forKey:CKDynamicLayoutLineBreakMode];
    
    return [self styleForViewWithKeyPath:@"textField" defaultStyle:defaultStyle];
}

- (CGSize)computeSize{
    NSString* text = nil;
    CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
    if(([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad && self.cellStyle == CKTableViewCellStyleIPadForm)
       || self.cellStyle != CKTableViewCellStyleIPhoneForm){
        text = _(descriptor.name);
    }
    NSString* textFieldText = [[self objectProperty]value];
    
    CGSize size = [self computeSizeUsingText:text detailText:textFieldText image:self.image];
    self.invalidatedSize = NO;
    
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    if(!readonly){
        if(self.cellStyle == CKTableViewCellStyleIPadForm
           || self.cellStyle == CKTableViewCellStyleIPhoneForm
           || self.cellStyle == CKTableViewCellStyleSubtitle2){
            
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSDictionary* textFieldStyle = [self textFieldStyle];
            if(self.cellStyle == CKTableViewCellStyleIPadForm
               || self.cellStyle == CKTableViewCellStyleIPhoneForm){
                CGRect frame = [self value3TextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                return CGSizeMake(320,frame.origin.y + frame.size.height + self.contentInsets.bottom);
            }else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                CGRect frame = [self subtitleTextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                return CGSizeMake(320,frame.origin.y + frame.size.height + self.contentInsets.bottom);
            }
        }else{
            NSAssert(NO,@"only CKTableViewCellStyleIPadForm, CKTableViewCellStyleIPhoneForm, CKTableViewCellStyleSubtitle2 are supported for CKNSStringPropertyCellController");
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
            
            UITableViewCell* cell = self.tableViewCell;
            UITextField *textField = (UITextField*)[cell viewWithTag:50000];
            if(textField){
                
                NSDictionary* textStyle = [self detailTextStyle];
                
                NSString* text = nil;
                CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
                if(([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad && self.cellStyle == CKTableViewCellStyleIPadForm)
                   || self.cellStyle != CKTableViewCellStyleIPhoneForm){
                    text = _(descriptor.name);
                }
                
                NSDictionary* textFieldStyle = [self textFieldStyle];
                NSString* textFieldText =[[self objectProperty]value];
                
                if(self.cellStyle == CKTableViewCellStyleIPadForm
                   || self.cellStyle == CKTableViewCellStyleIPhoneForm){
                    textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    textField.frame = [self value3TextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                    
                    //align textLabel on y
                    /*CGFloat txtFieldCenter = textField.y + (textField.height / 2.0);
                    CGFloat txtLabelHeight = cell.textLabel.height;
                    CGFloat txtLabelY = txtFieldCenter - (txtLabelHeight / 2.0);
                    cell.textLabel.y = txtLabelY;*/
                }
                else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                    textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                    textField.frame = [self subtitleTextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                }
            }
        }else{
            NSAssert(NO,@"only CKTableViewCellStyleIPadForm, CKTableViewCellStyleIPhoneForm, CKTableViewCellStyleSubtitle2 are supported for CKNSStringPropertyCellController");
        }
    }
}

@end

