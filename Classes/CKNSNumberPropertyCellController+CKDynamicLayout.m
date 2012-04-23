//
//  CKNSNumberPropertyCellController+CKDynamicLayout.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-19.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKNSNumberPropertyCellController+CKDynamicLayout.h"
#import "CKTableViewCellController+CKDynamicLayout.h"
#import "CKProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKUIView+Positioning.h"


#define TEXTFIELDINSETS 8
#define SWITCHHEIGHT 27
#define SWITCHWIDTH 79

@implementation CKNSNumberPropertyCellController(CKDynamicLayout)

- (CGRect)value3SwitchFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image{
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    CGFloat switchWidth = width - (self.contentInsets.right + self.componentsSpace);
    CGFloat switchX = self.contentInsets.left + (realWidth - (self.contentInsets.right + self.contentInsets.left) - switchWidth);
    
    return CGRectMake(switchX,self.contentInsets.top,SWITCHWIDTH,SWITCHHEIGHT);
}

- (CGRect)value3TextFieldFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textFieldText:(NSString*)textFieldText textFieldStyle:(NSDictionary*)textFieldStyle image:(UIImage*)image{
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    CGFloat textFieldWidth = width - (self.contentInsets.right + self.componentsSpace);
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
    return [self styleForViewWithKeyPath:@"textField" defaultStyle:nil];
}

- (CGFloat)componentsRatio{
    if(self.cellStyle == CKTableViewCellStylePropertyGrid
       && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if([[self objectProperty]isReadOnly] == NO && [self isBOOL]){
            return 0.3;
        }
    }
    return [super componentsRatio];
}

- (CGFloat)accessoryWidth{
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    if(!readonly){
        if([self isBOOL] && self.cellStyle != CKTableViewCellStyleValue3){
            return SWITCHWIDTH + (2 * 8);
        }
    }
    return [super accessoryWidth];
}

- (CGSize)computeSize{
    CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
    NSString* text = _(descriptor.name);
    
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    NSString* textFieldText = [self isNumber] ? 
                         [NSValueTransformer transform:[[self objectProperty]value] toClass:[NSString class]] 
                       : (readonly  ? ([[[self objectProperty] value]boolValue] ? @"YES" : @"NO") : nil);
    
    CGSize size = [self computeSizeUsingText:text detailText:textFieldText image:self.image];
    self.invalidatedSize = NO;
    
    if(!readonly){
        if(self.cellStyle == CKTableViewCellStyleValue3
           || self.cellStyle == CKTableViewCellStylePropertyGrid
           || self.cellStyle == CKTableViewCellStyleSubtitle2){
            
            NSDictionary* textStyle = [self detailTextStyle];
            
            if([self isNumber]){
                NSDictionary* textFieldStyle = [self textFieldStyle];
                if(self.cellStyle == CKTableViewCellStyleValue3
                   || self.cellStyle == CKTableViewCellStylePropertyGrid){
                    CGRect frame = [self value3TextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                    return CGSizeMake(320,MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom));
                }else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                    CGRect frame = [self subtitleTextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                    return CGSizeMake(320,MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom));
                }
            }else if([self isBOOL] && self.cellStyle == CKTableViewCellStyleValue3){
                CGRect frame = [self value3SwitchFrameUsingText:text textStyle:textStyle detailText:nil detailTextStyle:nil image:self.image];
                return CGSizeMake(320,MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom));
            }else{
                NSAssert(NO,@"only CKTableViewCellStyleValue3, CKTableViewCellStylePropertyGrid, CKTableViewCellStyleSubtitle2 are supported for CKNSNumberPropertyCellController");
            }
        }
    }
    return size;
}

- (void)performLayout{
    [super performLayout];
    
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    if(!readonly){
        if(self.cellStyle == CKTableViewCellStyleValue3
           || self.cellStyle == CKTableViewCellStylePropertyGrid
           || self.cellStyle == CKTableViewCellStyleSubtitle2){
            UITableViewCell* cell = self.tableViewCell;
            
            UISwitch* s = (UISwitch*)[cell viewWithTag:500002];
            UITextField *textField = (UITextField*)[cell viewWithTag:50000];
            
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSString* text = nil;
            CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad
               || self.cellStyle != CKTableViewCellStylePropertyGrid){
                text = _(descriptor.name);
            }
            
            if(textField && !s){
                NSDictionary* textFieldStyle = [self textFieldStyle];
                NSString* textFieldText = [NSValueTransformer transform:[[self objectProperty]value] toClass:[NSString class]];
                
                if(self.cellStyle == CKTableViewCellStyleValue3
                   || self.cellStyle == CKTableViewCellStylePropertyGrid){
                    textField.frame = [self value3TextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                
                    //align textLabel on y
                    CGFloat txtFieldCenter = textField.y + (textField.height / 2.0);
                    CGFloat txtLabelHeight = cell.textLabel.height;
                    CGFloat txtLabelY = txtFieldCenter - (txtLabelHeight / 2.0);
                    cell.textLabel.y = txtLabelY;
                }else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                    textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                    textField.frame = [self subtitleTextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                }
            }else if(s && self.cellStyle == CKTableViewCellStyleValue3){
                s.frame = [self value3SwitchFrameUsingText:text textStyle:textStyle detailText:nil detailTextStyle:nil image:self.image];
            }
        }else{
            NSAssert(NO,@"only CKTableViewCellStyleValue3, CKTableViewCellStylePropertyGrid, CKTableViewCellStyleSubtitle2 are supported for CKNSNumberPropertyCellController");
        }
    }
}


@end
