//
//  CKNSStringPropertyCellController+CKDynamicLayout.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-19.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKNSStringPropertyCellController+CKDynamicLayout.h"
#import "CKNSStringPropertyCellController.h"
#import "CKTableViewCellController+CKDynamicLayout.h"
#import "CKProperty.h"
#import "CKNSObject+bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "CKNSValueTransformer+Additions.h"

#import "CKSheetController.h"
#import "CKUIView+Positioning.h"


@implementation CKNSStringPropertyCellController(CKDynamicLayout)

- (CGRect)value3TextFieldFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textFieldText:(NSString*)textFieldText textFieldStyle:(NSDictionary*)textFieldStyle image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    CGFloat y = isIphone ? ((cell.contentView.frame.size.height / 2.0) - ((textField.font.lineHeight + 10) / 2.0)) : self.contentInsets.top;
    
    CGFloat rowWidth = [self computeContentViewSize];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    CGFloat textFieldWidth = width - (self.contentInsets.right + self.componentsSpace);
    CGFloat textFieldX = self.contentInsets.left + (realWidth - (self.contentInsets.right + self.contentInsets.left) - textFieldWidth);
    if(![cell.textLabel.text isKindOfClass:[NSString class]] || [cell.textLabel.text length] <= 0){
        textFieldWidth = realWidth - (self.contentInsets.left + self.contentInsets.right);
        textFieldX = self.contentInsets.left;
    }*/
}

- (CGRect)subtitleTextFieldFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textFieldText:(NSString*)textFieldText textFieldStyle:(NSDictionary*)textFieldStyle  image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*CGFloat x = cell.textLabel.x;
    CGRect textFrame = cell.textLabel.frame;
    CGFloat width = cell.contentView.width - x - 10;
    
    textField.frame = CGRectIntegral(CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10,width,(textField.font.lineHeight + 10)));*/
}

- (NSDictionary*)textFieldStyle{
    return [self styleForViewWithKeyPath:@"textField" defaultStyle:nil];
}

- (CGSize)computeSize{
    CGSize size = [super size];
    
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    if(!readonly){
        if(self.cellStyle == CKTableViewCellStyleValue3
           || self.cellStyle == CKTableViewCellStylePropertyGrid
           || self.cellStyle == CKTableViewCellStyleSubtitle2){
            
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSString* text = nil;
            CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                text = _(descriptor.name);
            }
            
            NSDictionary* textFieldStyle = [self textFieldStyle];
            NSString* textFieldText = [NSValueTransformer transform:[[self objectProperty]value] toClass:[NSString class]];
            if(self.cellStyle == CKTableViewCellStyleValue3
               || self.cellStyle == CKTableViewCellStylePropertyGrid){
                CGRect frame = [self value3TextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                return CGSizeMake(320,MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom));
            }else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                CGRect frame = [self subtitleTextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                return CGSizeMake(320,MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom));
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
            UITextField *textField = (UITextField*)[cell viewWithTag:50000];
            if(textField){
                
                NSDictionary* textStyle = [self detailTextStyle];
                
                NSString* text = nil;
                CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
                if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                    text = _(descriptor.name);
                }
                
                NSDictionary* textFieldStyle = [self textFieldStyle];
                NSString* textFieldText =[[self objectProperty]value];
                
                if(self.cellStyle == CKTableViewCellStyleValue3
                   || self.cellStyle == CKTableViewCellStylePropertyGrid){
                    textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                    textField.frame = [self value3TextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                    
                    //align textLabel on y
                    CGFloat txtFieldCenter = textField.y + (textField.height / 2.0);
                    CGFloat txtLabelHeight = cell.textLabel.height;
                    CGFloat txtLabelY = txtFieldCenter - (txtLabelHeight / 2.0);
                    cell.textLabel.y = txtLabelY;
                }
                else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                    textField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                    textField.frame = [self subtitleTextFieldFrameUsingText:text textStyle:textStyle textFieldText:textFieldText textFieldStyle:textFieldStyle image:self.image];
                }
            }
        }
    }
}

@end

