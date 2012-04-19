//
//  CKMultilineNSStringPropertyCellController+CKDynamicLayout.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-19.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKMultilineNSStringPropertyCellController+CKDynamicLayout.h"
#import "CKMultilineNSStringPropertyCellController.h"
#import "CKTableViewCellController+CKDynamicLayout.h"
#import "CKProperty.h"
#import "CKNSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "CKBindedTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Positioning.h"

@implementation CKMultilineNSStringPropertyCellController(CKDynamicLayout)

- (CGRect)value3TextViewFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textViewText:(NSString*)textViewText textViewStyle:(NSDictionary*)textViewStyle image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*UITableViewCell* cell = self.tableViewCell;
    if(self.cellStyle == CKTableViewCellStyleValue3){
        CGFloat rowWidth = [self computeContentViewSize];
        CGFloat realWidth = rowWidth;
        CGFloat width = realWidth * self.componentsRatio;
        
        CGFloat textFieldWidth = width - (self.contentInsets.right + self.componentsSpace);
        CGFloat textFieldX = self.contentInsets.left + (realWidth - (self.contentInsets.right + self.contentInsets.left) - textFieldWidth);
        
        CGFloat textFieldY = self.contentInsets.top;
        CGFloat textFieldHeight = cell.contentView.height - (self.contentInsets.top + self.contentInsets.bottom);
        self.textView.frame = CGRectMake(textFieldX,textFieldY,textFieldWidth,textFieldHeight);
    }*/
}

- (CGRect)propertyGridTextViewFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textViewText:(NSString*)textViewText textViewStyle:(NSDictionary*)textViewStyle image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(cell.textLabel.text == nil || 
           [cell.textLabel.text isKindOfClass:[NSNull class]] ||
           [cell.textLabel.text length] <= 0){
            CGRect textViewFrame = CGRectMake(3,0,cell.contentView.bounds.size.width - 6,self.textView.frame.size.height);
            self.textView.frame = textViewFrame;
        }
        else{
            //sets the textLabel on one full line and the textView beside
            CGRect textFrame = CGRectMake(10,0,cell.contentView.bounds.size.width - 20,28);
            cell.textLabel.frame = textFrame;
            
            CGRect textViewFrame = CGRectMake(3,30,cell.contentView.bounds.size.width - 6,self.textView.frame.size.height);
            self.textView.frame = textViewFrame;
        }
    }
    else{
        CGRect f = [self propertyGridDetailFrameForCell:cell];
        self.textView.frame = CGRectMake(f.origin.x - 8,f.origin.y - 8 ,f.size.width + 8,self.textView.frame.size.height);
    }*/
}

- (CGRect)subtitleTextViewFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textViewText:(NSString*)textViewText textViewStyle:(NSDictionary*)textViewStyle  image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*CGRect textViewFrame = CGRectMake(MAX(self.contentInsets.left,cell.textLabel.x),MAX(self.contentInsets.top,cell.textLabel.y + cell.textLabel.height + 10),cell.contentView.width - (cell.imageView.x + 10) - 10,self.textView.frame.size.height);
    self.textView.frame = textViewFrame;*/
}

- (NSDictionary*)textViewStyle{
    return [self styleForViewWithKeyPath:@"textView" defaultStyle:nil];
}

- (CGSize)computeSize{
    CGSize size = [super size];
    
    BOOL readonly = [[self objectProperty] isReadOnly] || self.readOnly;
    if(!readonly){
        if(self.cellStyle == CKTableViewCellStyleValue3
           || self.cellStyle == CKTableViewCellStylePropertyGrid
           || self.cellStyle == CKTableViewCellStyleSubtitle2){
            
            NSDictionary* textViewStyle = [self textViewStyle];
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSString* text = nil;
            CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                text = _(descriptor.name);
            }
            
            NSString* textViewText = [[self objectProperty]value];
            
            CGFloat height = 0;
            if(self.cellStyle == CKTableViewCellStyleValue3){
                CGRect frame = [self value3TextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
                height = MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom);
            }
            else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
                CGRect frame = [self propertyGridTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
                height = MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom);
            }
            else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                CGRect frame = [self subtitleTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
                height = MAX(size.height,frame.origin.y + frame.size.height + self.contentInsets.bottom);
            }    
            
            return CGSizeMake(320,height);
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
            
            NSDictionary* textViewStyle = [self textViewStyle];
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSString* text = nil;
            CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                text = _(descriptor.name);
            }
            
            NSString* textViewText = [[self objectProperty]value];
            
            UITableViewCell* cell = self.tableViewCell;
            CKTextView* textView = (CKTextView*)[cell viewWithTag:50000];
            
            if(self.cellStyle == CKTableViewCellStyleValue3){
                textView.frame = [self value3TextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
            }
            else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
                textView.frame = [self propertyGridTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
            }
            else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
                textView.frame = [self subtitleTextViewFrameUsingText:text textStyle:textStyle textViewText:textViewText textViewStyle:textViewStyle image:self.image];
            }
        }
    }
}

@end