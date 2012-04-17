//
//  CKTableViewCellController+CKDynamicLayout.m
//  CloudKit
//
//  Created by Sebastien Morel on 12-04-17.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+CKDynamicLayout.h"


#import "CKTableViewCellController.h"
#import "CKTableViewCellController+Style.h"
#import "CKUILabel+Style.h"
#import "CKBindedTableViewController.h"
#import "CKPropertyExtendedAttributes.h"
#import "CKPropertyExtendedAttributes+CKAttributes.h"
#import <objc/runtime.h>

#import "CKStyleManager.h"
#import "CKNSObject+Bindings.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Style.h"
#import "CKLocalization.h"

#import "CKUIView+Positioning.h"
#import "CKProperty.h"
#import "CKNSObject+CKSingleton.h"

@implementation CKTableViewCellController (CKDynamicLayout)

@dynamic componentsRatio, componentsSpace, contentInsets;


+ (CGFloat)contentViewWidthInParentController:(CKBindedTableViewController*)controller{
    CGFloat rowWidth = 0;
    UIView* tableViewContainer = [controller tableViewContainer];
    UITableView* tableView = [controller tableView];
    if(tableView.style == UITableViewStylePlain){
        rowWidth = tableViewContainer.frame.size.width;
    }
    else if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        rowWidth = tableViewContainer.frame.size.width - 18;
    }
    else{
        CGFloat tableViewWidth = tableViewContainer.frame.size.width;
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

- (CGSize)sizeForTextLabelConstraintToWidth:(CGFloat)width{
    if(!self.text){
        return CGSizeMake(0,0);
    }
    
    CGSize size = [self.text  sizeWithFont:[self textLabelFont]
                               constrainedToSize:CGSizeMake( width , CGFLOAT_MAX)];
    return size;
}

- (CGSize)sizeForDetailTextLabelConstraintToWidth:(CGFloat)width{
    if(!self.detailText){
        return CGSizeMake(0,0);
    }
    
    CGSize size = [self.detailText  sizeWithFont:[self detailTextLabelFont]
                               constrainedToSize:CGSizeMake( width , CGFLOAT_MAX)];
    return size;
}

//Value3 layout 
- (CGRect)value3DetailFrameForCell:(UITableViewCell*)cell{
    CGRect textFrame = [self value3TextFrameForCell:cell];
    
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    CGSize size = [self sizeForDetailTextLabelConstraintToWidth:width];
	
    BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    CGFloat y = isIphone ? ((cell.contentView.frame.size.height / 2.0) - (MAX(cell.detailTextLabel.font.lineHeight,size.height) / 2.0)) : self.contentInsets.top;
	return CGRectIntegral(CGRectMake((textFrame.origin.x + textFrame.size.width) + self.componentsSpace, y, 
                                     MIN(size.width,width) , MAX(textFrame.size.height,MAX(cell.detailTextLabel.font.lineHeight,size.height))));
}

- (CGRect)value3TextFrameForCell:(UITableViewCell*)cell{
    if(cell.textLabel.text == nil || 
       [cell.textLabel.text isKindOfClass:[NSNull class]] ||
       [cell.textLabel.text length] <= 0){
        return CGRectMake(0,0,0,0);
    }
    
    CGFloat rowWidth = [self contentViewWidth];
    CGFloat realWidth = rowWidth;
    CGFloat width = realWidth * self.componentsRatio;
    
    //Detail Check
    CGSize detailsize = [self sizeForDetailTextLabelConstraintToWidth:width];
    BOOL detailOn1Line = (detailsize.height == cell.detailTextLabel.font.lineHeight);
    
    CGFloat maxWidth = realWidth - width - self.componentsSpace;
    
    CGSize size = [self sizeForTextLabelConstraintToWidth:maxWidth];
    BOOL textOn1Line = (size.height == cell.textLabel.font.lineHeight);
    
    if(detailOn1Line && textOn1Line){
        size.height = MAX(cell.textLabel.font.lineHeight,cell.detailTextLabel.font.lineHeight);
    }
    
    BOOL isIphone = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    CGFloat y = isIphone ? ((cell.contentView.frame.size.height / 2.0) - (MAX(cell.textLabel.font.lineHeight,size.height) / 2.0)) : self.contentInsets.top;
    if(cell.textLabel.textAlignment == UITextAlignmentRight){
        return CGRectIntegral(CGRectMake(self.contentInsets.left + maxWidth - size.width,y,size.width,MAX(cell.textLabel.font.lineHeight,size.height)));
    }
    else if(cell.textLabel.textAlignment == UITextAlignmentLeft){
        return CGRectIntegral(CGRectMake(self.contentInsets.left,y,size.width,MAX(cell.textLabel.font.lineHeight,size.height)));
    }
    
    //else Center
    return CGRectIntegral(CGRectMake(self.contentInsets.left + (maxWidth - size.width) / 2.0,y,size.width,MAX(cell.textLabel.font.lineHeight,size.height)));
}

//PropertyGrid layout
- (CGRect)propertyGridDetailFrameForCell:(UITableViewCell*)cell{
    //TODO : factoriser un peu mieux ce code la ....
    CGRect textFrame = [self propertyGridTextFrameForCell:cell];
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(cell.textLabel.text == nil || 
           [cell.textLabel.text isKindOfClass:[NSNull class]] ||
           [cell.textLabel.text length] <= 0){
            if(cell.detailTextLabel.text != nil && 
               [cell.detailTextLabel.text isKindOfClass:[NSNull class]] == NO &&
               [cell.detailTextLabel.text length] > 0 &&
               cell.detailTextLabel.numberOfLines != 1){
                
                CGFloat realWidth = cell.contentView.frame.size.width;
                CGFloat maxWidth = realWidth - (self.contentInsets.left + self.contentInsets.right);
                CGSize size = [self sizeForDetailTextLabelConstraintToWidth:maxWidth];
                return CGRectMake(self.contentInsets.left,self.contentInsets.top, cell.contentView.frame.size.width - (self.contentInsets.left + self.contentInsets.right), size.height);
            }
            else{
                return CGRectMake(self.contentInsets.left,self.contentInsets.top, cell.contentView.frame.size.width - (self.contentInsets.left + self.contentInsets.right), MAX(cell.textLabel.font.lineHeight,textFrame.size.height));
            }
        }
        else{
            //CGRect textFrame = [self propertyGridTextFrameForCell:cell];
            CGFloat x = textFrame.origin.x + textFrame.size.width + self.componentsSpace;
            CGFloat width = cell.contentView.frame.size.width - self.contentInsets.right - x;
            if(width > 0 ){
                CGSize size = [self sizeForDetailTextLabelConstraintToWidth:width];
                CGFloat y = MAX(textFrame.origin.y + (textFrame.size.height / 2.0) - (size.height / 2),self.contentInsets.top);
                
                return CGRectMake(x,y, width, size.height);
            }
            else{
                return CGRectMake(0,0,0,0);
            }
        }
    }
    return [self value3DetailFrameForCell:cell];
}

- (CGRect)propertyGridTextFrameForCell:(UITableViewCell*)cell{
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        if(cell.textLabel.text == nil || 
           [cell.textLabel.text isKindOfClass:[NSNull class]] ||
           [cell.textLabel.text length] <= 0){
            return CGRectMake(0,0,0,0);
        }
        else{
            CGFloat rowWidth = [self contentViewWidth];
            CGFloat realWidth = rowWidth;
            CGFloat width = realWidth * self.componentsRatio;
            
            CGFloat maxWidth = realWidth - width - self.contentInsets.left - self.componentsSpace;
            CGSize size = [self sizeForTextLabelConstraintToWidth:maxWidth];
            return CGRectMake(self.contentInsets.left,self.contentInsets.top, size.width, size.height);
        }
    }
    return [self value3TextFrameForCell:cell];
}

- (CGRect)subtitleTextFrameForCell:(UITableViewCell*)cell{
    if(cell.textLabel.text == nil || 
       [cell.textLabel.text isKindOfClass:[NSNull class]] ||
       [cell.textLabel.text length] <= 0){
        return CGRectMake(0,0,0,0);
    }
    
    CGFloat x = cell.imageView.x + cell.imageView.width + 10;
    CGFloat width = cell.contentView.width - x - 10;
    
    CGSize size = [self sizeForTextLabelConstraintToWidth:width];
    return CGRectMake(x,11, size.width, size.height);
}


- (CGRect)subtitleDetailFrameForCell:(UITableViewCell*)cell{
    CGRect textFrame = [self subtitleTextFrameForCell:cell];
    CGFloat x = cell.imageView.x + cell.imageView.width + 10;
    CGFloat width = cell.contentView.width - x - 10;
    
    if(cell.detailTextLabel.text == nil || 
       [cell.detailTextLabel.text isKindOfClass:[NSNull class]] ||
       [cell.detailTextLabel.text length] <= 0){
        return CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10,width,0);
    }
    
    CGSize size = [self sizeForDetailTextLabelConstraintToWidth:width];
    return CGRectMake(x,textFrame.origin.y + textFrame.size.height + 10, width/*size.width*/, size.height);
}

- (void)performLayout{
    UITableViewCell* cell = self.tableViewCell;
    //You can overload this method if you need to update cell layout when cell is resizing.
	//for example you need to resize an accessory view that is not automatically resized as resizingmask are not applied on it.
	if(self.cellStyle == CKTableViewCellStyleValue3){
        
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
        
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self value3DetailFrameForCell:cell];
		}
		if(cell.textLabel != nil){
			CGRect textFrame = [self value3TextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
		}
	}
    else if(self.cellStyle == CKTableViewCellStylePropertyGrid){
        cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
        cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self propertyGridDetailFrameForCell:cell];
		}
		if(cell.textLabel != nil){
			CGRect textFrame = [self propertyGridTextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
		}
	}
    else if(self.cellStyle == CKTableViewCellStyleSubtitle2){
        cell.detailTextLabel.autoresizingMask = UIViewAutoresizingNone;
        cell.textLabel.autoresizingMask = UIViewAutoresizingNone;
		if(cell.textLabel != nil){
			CGRect textFrame = [self subtitleTextFrameForCell:cell];
			cell.textLabel.frame = textFrame;
		}
		if(cell.detailTextLabel != nil){
			cell.detailTextLabel.frame = [self subtitleDetailFrameForCell:cell];
		}
	}
}

- (UIFont*)fontForViewWithKeyPath:(NSString*)keyPath{
    id object = [self valueForKeyPath:keyPath];
    if(object){
        if([object respondsToSelector:@selector(font)]){
            return [object performSelector:@selector(font)];
        }
        return nil;
    }
    
    id currentObject = self;
    NSMutableDictionary* currentStyle = [self controllerStyle];
    
    NSArray* components = [keyPath componentsSeparatedByString:@"."];
    for(NSString* component in components){
        CKProperty* property = [CKProperty propertyWithObject:currentObject keyPath:component];
        currentObject = [property value];
        if(!currentObject){
            currentObject = [[property class]sharedInstance];
        }
        currentStyle = [currentStyle styleForObject:currentObject propertyName:property.name];
    }
    
    if([currentObject respondsToSelector:@selector(font)]){
        UIFont* font = [currentObject performSelector:@selector(font)];
        if(currentStyle){
            NSString* fontName = font.fontName;
            if([currentStyle containsObjectForKey:CKStyleFontName])
                fontName= [currentStyle fontName];
            CGFloat fontSize = font.pointSize;
            if([currentStyle containsObjectForKey:CKStyleFontSize])
                fontSize= [currentStyle fontSize];
            font = [UIFont fontWithName:fontName size:fontSize];
        }
        return font;
    }
    
    return nil;
}

- (UIFont*)textLabelFont{
    return [self fontForViewWithKeyPath:@"tableViewCell.textLabel"];
}

- (UIFont*)detailTextLabelFont{
    return [self fontForViewWithKeyPath:@"tableViewCell.detailTextLabel"];
}

- (CGFloat)contentViewWidth{
    return [CKTableViewCellController contentViewWidthInParentController:(CKBindedTableViewController*)self.containerController];
}

- (void)invalidateSize{
    //When tableView will wuery for the first time the size, it will set sizeHasBeenQueriedByTableView to YES and call invalidateSize for a first computation
    //after what, each time invalidateSize is called, the size will get recomputed.
    if(!self.sizeHasBeenQueriedByTableView)
        return;
    
    self.size = [self computeSize];
}

- (CGSize)computeSize{
    /*
     @property (nonatomic, assign) NSInteger indentationLevel;
     @property (nonatomic, retain) NSString* text;
     @property (nonatomic, retain) NSString* detailedText;
     @property (nonatomic, retain) UIImage*  image;
     @property (nonatomic) UITableViewCellAccessoryType   accessoryType;
     @property (nonatomic,retain) UIView                 *accessoryView;
     @property (nonatomic) UITableViewCellAccessoryType   editingAccessoryType;
     @property (nonatomic,retain) UIView                 *editingAccessoryView;
     */
    /*
    if(self.cellStyle == CKTableViewCellStyleValue3
       || self.cellStyle == CKTableViewCellStylePropertyGrid
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        CGFloat bottomText = staticController.tableViewCell.textLabel.frame.origin.y + staticController.tableViewCell.textLabel.frame.size.height;
        
        CGFloat bottomDetails = 0;
        if(staticController.tableViewCell.detailTextLabel.text != nil &&
           [staticController.tableViewCell.detailTextLabel.text isKindOfClass:[NSString class]] &&
           [staticController.tableViewCell.detailTextLabel.text length] > 0){
            bottomDetails = staticController.tableViewCell.detailTextLabel.frame.origin.y + staticController.tableViewCell.detailTextLabel.frame.size.height;
        }
        
        CGFloat maxHeight = MAX(44, MAX(bottomText,bottomDetails) + staticController.contentInsets.bottom);
        return [NSValue valueWithCGSize:CGSizeMake(tableWidth,maxHeight)];
    }
    return [NSValue valueWithCGSize:CGSizeMake(tableWidth,44)];
    NSAssert(NO,@"Do Implement this method");*/
}

@end
