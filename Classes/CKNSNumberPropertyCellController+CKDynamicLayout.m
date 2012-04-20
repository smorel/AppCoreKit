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

@implementation CKNSNumberPropertyCellController(CKDynamicLayout)

- (CGRect)value3SwitchFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*CGRect switchFrame = [self value3DetailFrameForCell:cell];
    CGFloat height = cell.bounds.size.height;
    CGRect rectForSwitch = CGRectMake(switchFrame.origin.x,(height/ 2.0) - (s.frame.size.height / 2.0),s.frame.size.width,s.frame.size.height);
    s.frame = CGRectIntegral(rectForSwitch);
     */
}

- (CGRect)value3TextFieldFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textFieldText:(NSString*)textFieldText textFieldStyle:(NSDictionary*)textFieldStyle image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*CGFloat realWidth = cell.contentView.frame.size.width;
    CGFloat textFieldX = (cell.textLabel.frame.origin.x + cell.textLabel.frame.size.width) + self.componentsSpace;
    CGFloat textFieldWidth = realWidth - self.contentInsets.right - textFieldX;
    textField.frame = CGRectIntegral(CGRectMake(textFieldX,self.contentInsets.top,textFieldWidth,textField.font.lineHeight + 10));
    
    //align textLabel on y
    CGFloat txtFieldCenter = textField.y + (textField.height / 2.0);
    CGFloat txtLabelHeight = cell.textLabel.height;
    CGFloat txtLabelY = txtFieldCenter - (txtLabelHeight / 2.0);
    cell.textLabel.y = txtLabelY;*/
}

- (CGRect)subtitleTextFieldFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle textFieldText:(NSString*)textFieldText textFieldStyle:(NSDictionary*)textFieldStyle  image:(UIImage*)image{
    NSAssert(NO,@"NOT IMPLEMENTED!");
    /*
     CGFloat x = cell.textLabel.x;
     CGRect textFrame = cell.textLabel.frame;
     CGFloat width = cell.contentView.width - x - 10;
     
     textField.frame = CGRectIntegral(CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10,width,(textField.font.lineHeight + 10)));*/
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

- (CGSize)computeSize{
    CGSize size = [super computeSize];
    
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
            
            if([self isNumber]){
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
            }else if([self isBOOL] && self.cellStyle == CKTableViewCellStyleValue3){
                NSDictionary* detailTextStyle = [self detailTextStyle];
                NSString* detailText = [[[self objectProperty] value]boolValue] ? @"YES" : @"NO";
                
                CGRect frame = [self value3SwitchFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailTextStyle image:self.image];
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
            
            UISwitch* s = (UISwitch*)[cell viewWithTag:500002];
            UITextField *textField = (UITextField*)[cell viewWithTag:50000];
            
            NSDictionary* textStyle = [self detailTextStyle];
            
            NSString* text = nil;
            CKClassPropertyDescriptor* descriptor = [[self objectProperty] descriptor];
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
                text = _(descriptor.name);
            }
            
            if(textField){
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
                NSDictionary* detailTextStyle = [self detailTextStyle];
                NSString* detailText = [[[self objectProperty] value]boolValue] ? @"YES" : @"NO";
                
                s.frame = [self value3SwitchFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailTextStyle image:self.image];
            }
        }
    }
}


@end
