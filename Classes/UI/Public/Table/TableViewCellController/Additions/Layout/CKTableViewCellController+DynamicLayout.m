//
//  CKTableViewCellController+DynamicLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+DynamicLayout.h"
#import "CKTableViewCellController+DynamicLayout_Private.h"


#import "CKTableViewCellController.h"
#import "CKTableViewCellController+Style.h"
#import "UILabel+Style.h"
#import "CKTableCollectionViewController.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import "UIFont+ValueTransformer.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "NSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Style.h"
#import "CKLocalization.h"

#import "UIView+Positioning.h"
#import "CKProperty.h"
#import "NSObject+Singleton.h"
#import "CKStyle+Parsing.h"
#import "CKVersion.h"
#import "CKStringHelper.h"
#import "CKViewCellCache.h"


#import "CKNSStringPropertyCellController.h"
#import "CKNSNumberPropertyCellController.h"
#import "CKMultilineNSStringPropertyCellController.h"

NSString* CKDynamicLayoutTextAlignment = @"CKDynamicLayoutTextAlignment";
NSString* CKDynamicLayoutFont          = @"CKDynamicLayoutFont";
NSString* CKDynamicLayoutNumberOfLines = @"CKDynamicLayoutNumberOfLines";
NSString* CKDynamicLayoutLineBreakMode = @"CKDynamicLayoutLineBreakMode";

@implementation CKTableViewCellController (CKDynamicLayout)

- (CGFloat)accessoryWidth{
    if(self.containerController.editing){
        return 0;
    }
    else if(self.accessoryView){
        return self.accessoryView.width;
    }
    else if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator
            || self.accessoryType == UITableViewCellAccessoryCheckmark){
        return 30;
    }else if(self.accessoryType == UITableViewCellAccessoryDetailDisclosureButton){
        return 43;
    }
    return 0;
}

- (CGFloat)editingWidth{
    if(self.flags & CKItemViewFlagRemovable && [self.containerController isEditing]){
        if(self.tableViewCell && ((CKUITableViewCell*)self.tableViewCell).editingMask == 3){
            return 32 + 75;
        }
        return 32;
    }
    return 0;
}

- (CGFloat)tableViewCellWidth{
    return [self computeTableViewCellViewSize];
}

- (CGFloat)contentViewWidth{
    return [self computeContentViewSize];
}

- (CGSize)computeSize{
    self.invalidatedSize = NO;
    
    if(self.cellStyle == CKTableViewCellStyleCustomLayout){
        //lock compute size when calling preferedHeightConstraintToWidth cause it invalidates layout wich is handle by tableViewCell to re-compute the size !
        self.sizeHasBeenQueriedByTableView = YES;
        
        if(self.tableViewCell){
            CKTableCollectionViewController* parentController = (CKTableCollectionViewController*)self.parentTableViewController;
            if(parentController && parentController.orientation == CKTableViewOrientationPortrait){
                CGFloat height = [(CKUITableViewCell*)self.tableViewCell preferedHeightConstraintToWidth:self.tableViewCell.contentView.width];
                self.sizeHasBeenQueriedByTableView = NO;
                return CGSizeMake([self tableViewCellWidth],(height >= MAXFLOAT) ? 0 : (height + ((parentController.tableView.separatorStyle != UITableViewCellSeparatorStyleNone) ? 1 : 0)));
            }else if(parentController){
                CGFloat width = [(CKUITableViewCell*)self.tableViewCell preferedWidthConstraintToHeight:self.tableViewCell.contentView.height];
                self.sizeHasBeenQueriedByTableView = NO;
                return CGSizeMake((width >= MAXFLOAT) ? 0 : width, [self tableViewCellWidth]);
            }else{
                //not a table (carousel ?)
                CGFloat width = [(CKUITableViewCell*)self.tableViewCell preferedWidthConstraintToHeight:self.containerController.view.height];
                self.sizeHasBeenQueriedByTableView = NO;
                return CGSizeMake((width >= MAXFLOAT) ? 0 : width, self.containerController.view.height);
            }
        }else{
            CKUITableViewCell* view = (CKUITableViewCell*)[[CKViewCellCache sharedInstance]reusableViewWithIdentifier:[self identifier]];
            
            if(!view){
                view = [[[CKUITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[self identifier]]autorelease];
                view.width = self.parentTableView.width;
                
                UIView* original = self.view; //For styles to apply correctly on view.
                self.view = view;
                
                [self initView:view];
                self.view = original;
                [[CKViewCellCache sharedInstance]setReusableView:view forIdentifier:[self identifier]];
            }
            
            UIView* original = self.view; //For styles to apply correctly on view.
            self.view = view;
            [self setupView:view];
            self.view = original;
            
            [view clearBindingsContext];
            
            CKTableCollectionViewController* parentController = (CKTableCollectionViewController*)self.parentTableViewController;
            if(parentController && parentController.orientation == CKTableViewOrientationPortrait){
                view.contentView.height = 100;
                view.contentView.width = [self contentViewWidth];
                
                CGFloat height = [view preferedHeightConstraintToWidth:view.contentView.width];
                self.sizeHasBeenQueriedByTableView = NO;
                return CGSizeMake([self tableViewCellWidth],(height >= MAXFLOAT) ? 0 : (height + ((parentController.tableView.separatorStyle != UITableViewCellSeparatorStyleNone) ? 1 : 0)));
            }else if(parentController){
                view.contentView.height = [self contentViewWidth];
                view.contentView.width = 100;
                
                CGFloat width = [view preferedWidthConstraintToHeight:view.contentView.height];
                self.sizeHasBeenQueriedByTableView = NO;
                return CGSizeMake((width >= MAXFLOAT) ? 0 : width, [self tableViewCellWidth]);
            }else{
                //not a table (carousel ?)
                CGFloat width = [view preferedWidthConstraintToHeight:self.containerController.view.height];
                self.sizeHasBeenQueriedByTableView = NO;
                return CGSizeMake((width >= MAXFLOAT) ? 0 : width, self.containerController.view.height);
            }
        }
    }
    
    return [self computeSizeUsingText:self.text detailText:self.detailText image:self.image];

}


@end












@implementation CKTableViewCellController (CKDynamicLayout_Private)

@dynamic invalidatedSize, parentCellController, isInSetup,textLabelStyle,detailTextLabelStyle,sizeHasBeenQueriedByTableView;

+ (CGFloat)computeTableViewCellViewSizeUsingTableView:(UITableView*)tableView{
    CGFloat rowWidth = 0;
    CGFloat tableViewWidth = tableView.frame.size.width;
    
    if([CKOSVersion() floatValue] >= 7){
        return tableViewWidth;
    }
    
    
    
    if(tableView.style == UITableViewStylePlain){
        rowWidth = tableViewWidth;
    }
    else if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        rowWidth = tableViewWidth - 18;
    }
    else{
        CGFloat offset = -1;
        if(tableViewWidth > 716)offset = 90;
        else if(tableViewWidth > 638) offset = 88 - (((NSInteger)(716 - tableViewWidth) / 13) * 2);
        else if(tableViewWidth > 624) offset = 76;
        else if(tableViewWidth > 545) offset = 74 - (((NSInteger)(624 - tableViewWidth) / 13) * 2);
        else if(tableViewWidth > 400) offset = 62;
        else offset = 20;
        
        rowWidth = tableViewWidth - offset;
    }
    
    return rowWidth;
}

+ (CGFloat)computeTableViewCellMarginUsingTableView:(UITableView*)tableView{
    if([CKOSVersion() floatValue] >= 7){
        return 0;
    }

    
    CGFloat rowWidth = [CKTableViewCellController computeTableViewCellViewSizeUsingTableView:tableView];
    CGFloat allMArgins = tableView.frame.size.width - rowWidth;
    return allMArgins / 2;
}

- (CGFloat)computeTableViewCellViewSize{
    UITableView* tableView = [(CKTableViewController*)self.containerController tableView];
    return [CKTableViewCellController computeTableViewCellViewSizeUsingTableView:tableView];
}

- (CGFloat)computeContentViewSizeForSubCellController{
    return [self computeTableViewCellViewSize] - [self accessoryWidth] - [self editingWidth];
}

- (CGFloat)computeContentViewSize{
    if(self.parentCellController){
        return [self.parentCellController computeContentViewSizeForSubCellController]  - [self accessoryWidth] - [self editingWidth];
    }
    
    
    return [self computeTableViewCellViewSize] - [self accessoryWidth] - [self editingWidth];
}


- (CGSize)sizeForText:(NSString*)text withStyle:(NSDictionary*)style constraintToWidth:(CGFloat)width{
    if(!text || [text isKindOfClass:[NSNull class]]|| [text length] <= 0){
        return CGSizeMake(0,0);
    }
    
    UIFont* font = [style objectForKey:CKDynamicLayoutFont];
    
    NSInteger numberOfLines = [[style objectForKey:CKDynamicLayoutNumberOfLines]intValue];
    CGFloat maxHeight = (numberOfLines <= 0) ? CGFLOAT_MAX : numberOfLines * font.lineHeight;
    
    CGSize size = [CKStringHelper sizeForText:text font:font constrainedToSize:CGSizeMake(width , maxHeight) lineBreakMode:[[style objectForKey:CKDynamicLayoutLineBreakMode]intValue]];
    return size;
}

//CKTableViewCellStyleIPadForm

- (CGRect)value3TextFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image{
    /*
     TODO : Take care of indentation level !
     Take care of image
     */
    
    UIFont* detailTextFont = [detailTextStyle objectForKey:CKDynamicLayoutFont];
    UIFont* textFont = [textStyle objectForKey:CKDynamicLayoutFont];
    UITextAlignment textAlignment = [[textStyle objectForKey:CKDynamicLayoutTextAlignment]intValue];
    
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    //Detail Check
    CGSize detailsize = [self sizeForText:detailText withStyle:detailTextStyle constraintToWidth:width];
    BOOL detailOn1Line = (detailsize.height == detailTextFont.lineHeight);
    
    CGFloat maxWidth = realWidth - width - self.horizontalSpace;
    
    CGSize size = [self sizeForText:text withStyle:textStyle constraintToWidth:maxWidth];
    BOOL textOn1Line = (size.height == textFont.lineHeight);
    
    if(detailOn1Line && textOn1Line){
        size.height = MAX(textFont.lineHeight,detailTextFont.lineHeight);
    }
    
    CGFloat totalHeight = size.height + self.contentInsets.top + self.contentInsets.bottom;
    
    BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    CGFloat y = isIphone ? ((totalHeight / 2.0) - (MAX(textFont.lineHeight,size.height) / 2.0)) : self.contentInsets.top;
    
    if(textAlignment == UITextAlignmentRight){
        return CGRectIntegral(CGRectMake(self.contentInsets.left + maxWidth - size.width,y,size.width,MAX(textFont.lineHeight,size.height)));
    }
    else if(textAlignment == UITextAlignmentLeft){
        return CGRectIntegral(CGRectMake(self.contentInsets.left,y,size.width,MAX(textFont.lineHeight,size.height)));
    }
    //else Center
    return CGRectIntegral(CGRectMake(self.contentInsets.left + (maxWidth - size.width) / 2.0,y,size.width,MAX(textFont.lineHeight,size.height)));
}

- (CGRect)value3DetailFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image{
    /*
     TODO : Take care of indentation level !
     Take care of image
     */
    
    UIFont* detailTextFont = [detailTextStyle objectForKey:CKDynamicLayoutFont];
    UIFont* textFont = [textStyle objectForKey:CKDynamicLayoutFont];
    
    CGRect textFrame = [self value3TextFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailTextStyle image:image];
    
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = (realWidth * self.componentsRatio) - (self.contentInsets.right + self.horizontalSpace);
    
    CGSize size = [self sizeForText:detailText withStyle:detailTextStyle constraintToWidth:width];
    
	
    BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    //here we want to center detail text to first line text on iphone.
    CGFloat y = self.contentInsets.top;
    if(isIphone && textFrame.size.height > 0){
        CGFloat offset = (textFont.lineHeight - detailTextFont.lineHeight) / 2;
        y += offset;
    }
    
    // CGFloat maxHeight = MAX(textFrame.origin.y + textFrame.size.height,size.height + self.contentInsets.top) + self.contentInsets.bottom;
    // CGFloat y = isIphone ? ((maxHeight / 2.0) - (MAX(detailTextFont.lineHeight,size.height) / 2.0)) : self.contentInsets.top;
    
	return CGRectIntegral(CGRectMake((textFrame.origin.x + textFrame.size.width) + self.horizontalSpace, y, 
                                     MIN(size.width,width) , size.height));
}

//CKTableViewCellStyleIPhoneForm

- (CGRect)propertyGridTextFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image{
    /*
     TODO : Take care of indentation level !
     Take care of image
     */
    
    //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
    if(text == nil || 
       [text isKindOfClass:[NSNull class]] ||
       [text length] <= 0){
        return CGRectMake(0,0,0,0);
    }
    else{
        CGFloat rowWidth = [self contentViewWidth];
        CGFloat realWidth = rowWidth;
        CGFloat width = (detailText == nil) ? 0 : realWidth * self.componentsRatio;
        
        CGFloat maxWidth = realWidth - width - self.contentInsets.left - ((detailText == nil) ? self.contentInsets.right : self.horizontalSpace);
        CGSize size = [self sizeForText:text withStyle:textStyle constraintToWidth:maxWidth];
        return CGRectIntegral(CGRectMake(self.contentInsets.left,self.contentInsets.top, size.width, size.height));
    }
    //}
    //return [self value3TextFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailTextStyle image:image];
}

- (CGRect)propertyGridDetailFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image{
    /*
     TODO : Take care of indentation level !
     Take care of image
     */
    
    CGFloat realWidth = [self contentViewWidth];
    
    //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
    if(text == nil || [text isKindOfClass:[NSNull class]] ||[text length] <= 0){
        NSInteger detailNumberOfLines = [[detailTextStyle objectForKey:CKDynamicLayoutNumberOfLines]intValue];
        if(detailText != nil && [detailText isKindOfClass:[NSNull class]] == NO && [detailText length] > 0 && detailNumberOfLines != 1){
            CGFloat maxWidth = realWidth - (self.contentInsets.left + self.contentInsets.right);
            CGSize size = [self sizeForText:detailText withStyle:detailTextStyle constraintToWidth:maxWidth];
            return CGRectIntegral(CGRectMake(self.contentInsets.left,self.contentInsets.top, realWidth - (self.contentInsets.left + self.contentInsets.right), size.height));
        }
        else{
            CGRect textFrame = [self propertyGridTextFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailTextStyle image:image];
            
            UIFont* textFont = [textStyle objectForKey:CKDynamicLayoutFont];
            return CGRectIntegral(CGRectMake(self.contentInsets.left,self.contentInsets.top, realWidth - (self.contentInsets.left + self.contentInsets.right), MAX(textFont.lineHeight,textFrame.size.height)));
        }
    }
    else{
        CGRect textFrame = [self propertyGridTextFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailTextStyle image:image];
        CGFloat x = textFrame.origin.x + textFrame.size.width + self.horizontalSpace;
        CGFloat width = realWidth - self.contentInsets.right - x;
        if(width > 0 ){
            CGSize size = [self sizeForText:detailText withStyle:detailTextStyle constraintToWidth:width];
            CGFloat y = MAX(textFrame.origin.y + (textFrame.size.height / 2.0) - (size.height / 2),self.contentInsets.top);
            
            return CGRectIntegral(CGRectMake(x,y, width, size.height));
        }
        else{
            return CGRectMake(0,0,0,0);
        }
    }
    //}
    //return [self value3DetailFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailTextStyle image:image];
}

//CKTableViewCellStyleSubtitle2

- (CGFloat)subtitleHeightForText:(NSString*)text textStyle:(NSDictionary*)textStyle image:(UIImage*)image{
    CGFloat x = self.contentInsets.left + (image ? (image.size.width + self.horizontalSpace) : 0);
    CGFloat width = [self contentViewWidth] - x  - self.contentInsets.right;
    
    CGSize size = [self sizeForText:text withStyle:textStyle constraintToWidth:width];
    return size.height;
}

- (CGRect)subtitleTextFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image{
    CGFloat x = self.contentInsets.left + (image ? (image.size.width + self.horizontalSpace) : 0);
    CGFloat width = [self contentViewWidth] - x  - self.contentInsets.right;
    
    /*
     TODO : Take care of indentation level !
     Take care of image
     */
    if(!text || [text length] <= 0){
        return CGRectMake(x,self.contentInsets.top,width,0);
    }
    
    CGFloat textHeight = [self subtitleHeightForText:text textStyle:textStyle image:image];
    CGFloat detailTextHeight = [self subtitleHeightForText:detailText textStyle:detailTextStyle image:image];
    
    BOOL hasText = !(text == nil || [text isKindOfClass:[NSNull class]] || [text length] <= 0);
    BOOL hasDetailText = !(detailText == nil || [detailText isKindOfClass:[NSNull class]] || [detailText length] <= 0);
    
    CGFloat textGlobalHeight = self.contentInsets.top + (hasText ? (textHeight + self.verticalSpace) : 0) + (hasDetailText ? detailTextHeight : 0) + self.contentInsets.bottom;
    CGFloat imageGlobalHeight = image ? (image.size.height + self.contentInsets.top + self.contentInsets.bottom) : 0;
    
    CGFloat yOffset = 0;
    if(imageGlobalHeight > textGlobalHeight){
        yOffset = (imageGlobalHeight - textGlobalHeight) / 2;
    }
    
    
    //CGSize size = [self sizeForText:text withStyle:textStyle constraintToWidth:width];
    return CGRectIntegral(CGRectMake(x,self.contentInsets.top + yOffset, width, textHeight));
}


- (CGRect)subtitleDetailFrameUsingText:(NSString*)text textStyle:(NSDictionary*)textStyle detailText:(NSString*)detailText detailTextStyle:(NSDictionary*)detailTextStyle image:(UIImage*)image textFrame:(CGRect)textFrame{
    /*
     TODO : Take care of indentation level !
     Take care of image
     */
    
    CGFloat x = self.contentInsets.left + (image ? (image.size.width + self.horizontalSpace) : 0);
    CGFloat width = [self contentViewWidth] - x  - self.contentInsets.right;
    
    if(detailText == nil || [detailText isKindOfClass:[NSNull class]] || [detailText length] <= 0){
        return CGRectIntegral(CGRectMake(x,textFrame.origin.y + textFrame.size.height,width,0));
    }
    
    CGSize size = [self sizeForText:detailText withStyle:detailTextStyle constraintToWidth:width];
    CGRect detailFrame = CGRectIntegral(CGRectMake(x,textFrame.origin.y + textFrame.size.height + ((textFrame.size.height > 0) ? self.verticalSpace : 0), width/*size.width*/, size.height));
    
    return detailFrame;
}

- (NSMutableDictionary*)styleForViewWithKeyPath:(NSString*)keyPath defaultStyle:(NSDictionary*)defaultStyle{
    if(!defaultStyle){
        NSMutableDictionary * def = [NSMutableDictionary dictionary];
        [def setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
        [def setObject:[UIFont systemFontOfSize:[UIFont systemFontSize]] forKey:CKDynamicLayoutFont];
        [def setObject:[NSNumber numberWithInt:UILineBreakModeWordWrap] forKey:CKDynamicLayoutLineBreakMode];
        [def setObject:[NSNumber numberWithInt:0] forKey:CKDynamicLayoutNumberOfLines];
        defaultStyle = def;
    }
    
    NSMutableDictionary* style = [NSMutableDictionary dictionaryWithDictionary:defaultStyle];
    
    //QUERY THE EXISTING VIEW
    id object = [self valueForKeyPath:keyPath];
    if(object){
        //font
        if([object respondsToSelector:@selector(font)]){
            UIFont* font = [object performSelector:@selector(font)];
            [style setObject:font forKey:CKDynamicLayoutFont];
        }
        
        //textAlignment
        if([object respondsToSelector:@selector(textAlignment)]){
            NSMethodSignature *signature = [object methodSignatureForSelector:@selector(textAlignment)];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:@selector(textAlignment)];
            [invocation setTarget:object];
            [invocation invoke];
            
            UITextAlignment textAlignment = UITextAlignmentLeft;
            [invocation getReturnValue:&textAlignment];
            
            [style setObject:[NSNumber numberWithInt:textAlignment] forKey:CKDynamicLayoutTextAlignment];
        }
        
        //lineBreakMode
        if([object respondsToSelector:@selector(lineBreakMode)]){
            NSMethodSignature *signature = [object methodSignatureForSelector:@selector(lineBreakMode)];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:@selector(lineBreakMode)];
            [invocation setTarget:object];
            [invocation invoke];
            
            UILineBreakMode lineBreakMode = UILineBreakModeWordWrap;
            [invocation getReturnValue:&lineBreakMode];
            
            [style setObject:[NSNumber numberWithInt:lineBreakMode] forKey:CKDynamicLayoutLineBreakMode];
        }
        
        //numberOfLines
        if([object respondsToSelector:@selector(numberOfLines)]){
            NSMethodSignature *signature = [object methodSignatureForSelector:@selector(numberOfLines)];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setSelector:@selector(numberOfLines)];
            [invocation setTarget:object];
            [invocation invoke];
            
            NSInteger numberOfLines = 0;
            [invocation getReturnValue:&numberOfLines];
            
            [style setObject:[NSNumber numberWithInteger:numberOfLines] forKey:CKDynamicLayoutNumberOfLines];
        }
        
        return style;
    }
    
    //QUERY STYLESHEETS
    
    NSMutableDictionary* currentStyle = [self controllerStyle];
    if(currentStyle && ![currentStyle isEmpty]){
        id currentObject = self;
        
        NSArray* components = [keyPath componentsSeparatedByString:@"."];
        for(NSString* component in components){
            CKProperty* property = [CKProperty propertyWithObject:currentObject keyPath:component];
            currentObject = [property value];
            if(!currentObject){
                currentObject = [[property type]sharedInstance];
            }
            currentStyle = [currentStyle styleForObject:currentObject propertyName:property.name];
        }
        
        if(currentStyle){
            //font
            UIFont* font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            
            if([currentStyle containsObjectForKey:@"font"]){
                font = (UIFont*)[NSValueTransformer transform:[currentStyle objectForKey:@"font"] toClass:[UIFont class]];
            }else{
                NSString* fontName = font.fontName;
                if([currentStyle containsObjectForKey:CKStyleFontName])
                    fontName= [currentStyle fontName];
                CGFloat fontSize = font.pointSize;
                if([currentStyle containsObjectForKey:CKStyleFontSize])
                    fontSize= [currentStyle fontSize];
                font = [UIFont fontWithName:fontName size:fontSize];
            }
            [style setObject:font forKey:CKDynamicLayoutFont];
            
            //textAlignment
            if([currentStyle containsObjectForKey:@"textAlignment"]){
                NSInteger value = [currentStyle enumValueForKey:@"textAlignment" withEnumDescriptor:CKEnumDefinition(@"UITextAlignment",
                                                                                                                     UITextAlignmentLeft,
                                                                                                                     UITextAlignmentCenter,
                                                                                                                     UITextAlignmentRight)];
                [style setObject:[NSNumber numberWithInteger:value] forKey:CKDynamicLayoutTextAlignment];
            }
            
            //numberOfLines
            if([currentStyle containsObjectForKey:@"numberOfLines"]){
                NSInteger value = [currentStyle integerForKey:@"numberOfLines"];
                [style setObject:[NSNumber numberWithInteger:value] forKey:CKDynamicLayoutNumberOfLines];
            }
            
            //lineBreakMode
            if([currentStyle containsObjectForKey:@"lineBreakMode"]){
                NSInteger value = [currentStyle enumValueForKey:@"lineBreakMode" withEnumDescriptor:CKEnumDefinition(@"UILineBreakMode",
                                                                                                                     UILineBreakModeWordWrap,            
                                                                                                                     UILineBreakModeCharacterWrap,           
                                                                                                                     UILineBreakModeClip,                    
                                                                                                                     UILineBreakModeHeadTruncation,          
                                                                                                                     UILineBreakModeTailTruncation,
                                                                                                                     UILineBreakModeMiddleTruncation)];
                [style setObject:[NSNumber numberWithInteger:value] forKey:CKDynamicLayoutLineBreakMode];
            }
        }
    }
    
    return style;
}

- (NSDictionary*)textStyle{
    if(!self.textLabelStyle){
        CKTableViewCellStyle cellStyle = self.cellStyle;
        //INIT DEAFAULT VALUES
        NSMutableDictionary* defaultStyle = [NSMutableDictionary dictionary];
        [defaultStyle setObject:[NSNumber numberWithInt:UILineBreakModeWordWrap] forKey:CKDynamicLayoutLineBreakMode];
        [defaultStyle setObject:[NSNumber numberWithInt:0] forKey:CKDynamicLayoutNumberOfLines];
        
        if(cellStyle == CKTableViewCellStyleIPadForm){
            [defaultStyle setObject:[UIFont boldSystemFontOfSize:17] forKey:CKDynamicLayoutFont];
            [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentRight] forKey:CKDynamicLayoutTextAlignment];
        }
        else if(cellStyle == CKTableViewCellStyleIPhoneForm){
            //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            [defaultStyle setObject:[UIFont boldSystemFontOfSize:17] forKey:CKDynamicLayoutFont];
            [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
            //}
            //else{
            //    [defaultStyle setObject:[UIFont boldSystemFontOfSize:17] forKey:CKDynamicLayoutFont];
            //    [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentRight] forKey:CKDynamicLayoutTextAlignment];
            //}
        }
        else if(cellStyle == CKTableViewCellStyleSubtitle2){
            [defaultStyle setObject:[UIFont boldSystemFontOfSize:17] forKey:CKDynamicLayoutFont];
            [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
        }
        
        self.textLabelStyle = [self styleForViewWithKeyPath:@"tableViewCell.textLabel" defaultStyle:defaultStyle];
    }
    return self.textLabelStyle;
}

- (NSDictionary*)detailTextStyle{
    if(!self.detailTextLabelStyle){
        NSMutableDictionary* defaultStyle = [NSMutableDictionary dictionary];
        [defaultStyle setObject:[NSNumber numberWithInt:UILineBreakModeWordWrap] forKey:CKDynamicLayoutLineBreakMode];
        [defaultStyle setObject:[NSNumber numberWithInt:0] forKey:CKDynamicLayoutNumberOfLines];
        
        CKTableViewCellStyle cellStyle = self.cellStyle;
        
        if(cellStyle == CKTableViewCellStyleIPadForm){
            [defaultStyle setObject:[UIFont systemFontOfSize:17] forKey:CKDynamicLayoutFont];
            [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
        }
        else if(cellStyle == CKTableViewCellStyleIPhoneForm){
            //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            [defaultStyle setObject:[UIFont systemFontOfSize:17] forKey:CKDynamicLayoutFont];
            [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentRight] forKey:CKDynamicLayoutTextAlignment];
            //}
            //else{
            //    [defaultStyle setObject:[UIFont systemFontOfSize:17] forKey:CKDynamicLayoutFont];
            //    [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
            //}
        }
        else if(cellStyle == CKTableViewCellStyleSubtitle2){
            [defaultStyle setObject:[UIFont systemFontOfSize:14] forKey:CKDynamicLayoutFont];
            [defaultStyle setObject:[NSNumber numberWithInt:UITextAlignmentLeft] forKey:CKDynamicLayoutTextAlignment];
        }
        
        self.detailTextLabelStyle = [self styleForViewWithKeyPath:@"tableViewCell.detailTextLabel" defaultStyle:defaultStyle];
    }
    return self.detailTextLabelStyle;
}

- (void)invalidateSize{
    if(self.isInSetup)
        return;
    
    CKTableViewCellStyle cellStyle = self.cellStyle;
	if(cellStyle == CKTableViewCellStyleIPadForm
       || cellStyle == CKTableViewCellStyleIPhoneForm
       || cellStyle == CKTableViewCellStyleSubtitle2
       || cellStyle == CKTableViewCellStyleCustomLayout){
        
        //When tableView will wuery for the first time the size, it will set sizeHasBeenQueriedByTableView to YES and call invalidateSize for a first computation
        //after what, each time invalidateSize is called, the size will get recomputed.
        if(self.sizeHasBeenQueriedByTableView)
            return;
        
        CGSize s;
        if(self.sizeBlock){
            s = self.sizeBlock(self);
        }else{
            s = [self computeSize];
        }
        
        if(!CGSizeEqualToSize(s, self.size)){
            self.invalidatedSize = YES;
            [super invalidateSize];
        }
    }
}

- (void)setSize:(CGSize)s notifyingContainerForUpdate:(BOOL)notifyingContainerForUpdate{
    if(CGSizeEqualToSize(self.size, s))
        return;
    
    [super setSize:s notifyingContainerForUpdate:notifyingContainerForUpdate];
}


- (CGSize)computeSizeUsingText:(NSString*)text detailText:(NSString*)detailText image:(UIImage*)image{
    CKTableViewCellStyle cellStyle = self.cellStyle;
    if(cellStyle == CKTableViewCellStyleIPadForm
       || cellStyle == CKTableViewCellStyleIPhoneForm
       || cellStyle == CKTableViewCellStyleSubtitle2){
        /*
         TODO : Take care of indentation level !
         Take care of image
         */
        
        NSDictionary* textStyle = [self textStyle];
        NSDictionary* detailStyle = [self detailTextStyle];
        
        CGFloat height = 0;
        if(cellStyle == CKTableViewCellStyleIPadForm){
            CGRect detailTextFrame = [self value3DetailFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailStyle image:self.image];
            CGRect textFrame = [self value3TextFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailStyle image:self.image];
            height = MAX(detailTextFrame.origin.y + detailTextFrame.size.height,textFrame.origin.y + textFrame.size.height) + self.contentInsets.bottom;
        }
        else if(cellStyle == CKTableViewCellStyleIPhoneForm){
            CGRect detailTextFrame = [self propertyGridDetailFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailStyle image:self.image];
            CGRect textFrame = [self propertyGridTextFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailStyle image:self.image];
            height = MAX(detailTextFrame.origin.y + detailTextFrame.size.height,textFrame.origin.y + textFrame.size.height) + self.contentInsets.bottom;
        }
        else if(cellStyle == CKTableViewCellStyleSubtitle2){
            CGRect textFrame = [self subtitleTextFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailStyle image:self.image];
            CGRect detailTextFrame = [self subtitleDetailFrameUsingText:text textStyle:textStyle detailText:detailText detailTextStyle:detailStyle image:self.image textFrame:textFrame];
            height = MAX(detailTextFrame.origin.y + detailTextFrame.size.height,textFrame.origin.y + textFrame.size.height) + self.contentInsets.bottom;
            
            CGFloat imageHeight = (image ? (image.size.height + self.contentInsets.top + self.contentInsets.bottom) : 0);
            height = MAX(height,imageHeight);
        }    
        
        return CGSizeMake([self tableViewCellWidth],height);
    }
    
    return self.size;
}


- (void)onValueChanged{
    
}

@end



@implementation CKTableViewCellController(CKLayout)


- (void)performLayout{
    CKTableViewCellStyle cellStyle = self.cellStyle;
    if(cellStyle == CKTableViewCellStyleCustomLayout){
        return;
    }
    
    if(cellStyle == CKTableViewCellStyleIPadForm
       || cellStyle == CKTableViewCellStyleIPhoneForm
       || cellStyle == CKTableViewCellStyleSubtitle2){
        UITableViewCell* cell = self.tableViewCell;
        
        NSDictionary* textStyle = [self textStyle];
        NSDictionary* detailStyle = [self detailTextStyle];
        
        /*
         TODO : Take care of indentation level !
         Take care of image
         */
        
        
        if(cellStyle == CKTableViewCellStyleIPadForm){
            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
                cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            }
            
            if(cell.detailTextLabel != nil){
                cell.detailTextLabel.frame = [self value3DetailFrameUsingText:self.text textStyle:textStyle detailText:self.detailText detailTextStyle:detailStyle image:self.image];
            }
            if(cell.textLabel != nil){
                CGRect textFrame = [self value3TextFrameUsingText:self.text textStyle:textStyle detailText:self.detailText detailTextStyle:detailStyle image:self.image];
                cell.textLabel.frame = textFrame;
            }
        }
        else if(cellStyle == CKTableViewCellStyleIPhoneForm){
            cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
            cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
            if(cell.detailTextLabel != nil){
                cell.detailTextLabel.frame = [self propertyGridDetailFrameUsingText:self.text textStyle:textStyle detailText:self.detailText detailTextStyle:detailStyle image:self.image];
            }
            if(cell.textLabel != nil){
                CGRect textFrame = [self propertyGridTextFrameUsingText:self.text textStyle:textStyle detailText:self.detailText detailTextStyle:detailStyle image:self.image];
                cell.textLabel.frame = textFrame;
            }
        }
        else if(cellStyle == CKTableViewCellStyleSubtitle2){
            cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
            cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
            
            //ADJUST FRAMES HERE DEPENDING ON CELL SIZE THAT COULD BE DIFFERENT THAN THE 'IDEAL' SIZE
            
            CGRect textFrame = [self subtitleTextFrameUsingText:self.text textStyle:textStyle detailText:self.detailText detailTextStyle:detailStyle image:self.image];
            CGRect detailFrame = [self subtitleDetailFrameUsingText:self.text textStyle:textStyle detailText:self.detailText detailTextStyle:detailStyle image:self.image textFrame:textFrame];
            
            if(!([self isKindOfClass:[CKNSStringPropertyCellController class] ] || [self isKindOfClass:[CKNSNumberPropertyCellController class] ] || [self isKindOfClass:[CKMultilineNSStringPropertyCellController class] ])){
                CGFloat textsHeight = detailFrame.origin.y + detailFrame.size.height - textFrame.origin.y;
                CGFloat y = ((cell.contentView.height - self.contentInsets.top - self.contentInsets.bottom - textsHeight) / 2);
                CGFloat yOffset = self.contentInsets.top + y - textFrame.origin.y;
                textFrame.origin.y += yOffset;
                detailFrame.origin.y += yOffset;
            }
            
            if(cell.textLabel != nil){
                cell.textLabel.frame = CGRectIntegral(textFrame);
            }
            
            if(cell.detailTextLabel != nil){
                cell.detailTextLabel.frame = CGRectIntegral(detailFrame);
            }
        }
    }
}

@end