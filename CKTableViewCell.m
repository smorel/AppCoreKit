//
//  CKTableViewCellController.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCell.h"
#import "CKVersion.h"
#import "CKResourceManager.h"

#define DisclosureImageViewTag  8888991
#define CheckmarkImageViewTag   8888992



@implementation CKTableViewCell
@synthesize disclosureIndicatorImage = _disclosureIndicatorImage;
@synthesize disclosureButton = _disclosureButton;
@synthesize checkMarkImage = _checkMarkImage;
@synthesize highlightedDisclosureIndicatorImage = _highlightedDisclosureIndicatorImage;
@synthesize highlightedCheckMarkImage = _highlightedCheckMarkImage;

- (void)dealloc{
    [_disclosureIndicatorImage release];
    _disclosureIndicatorImage = nil;
    [_disclosureButton release];
    _disclosureButton = nil;
    [_highlightedDisclosureIndicatorImage release];
    _highlightedDisclosureIndicatorImage = nil;
    [_highlightedCheckMarkImage release];
    _highlightedCheckMarkImage = nil;
    [_checkMarkImage release];
    _checkMarkImage = nil;
    [super dealloc];
}

- (void)setDisclosureIndicatorImage:(UIImage*)img{
    [_disclosureIndicatorImage release];
    _disclosureIndicatorImage = [img retain];
    if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator){
        UIImageView* view = [[[UIImageView alloc]initWithImage:_disclosureIndicatorImage]autorelease];
        view.highlightedImage = _highlightedDisclosureIndicatorImage;
        view.tag = DisclosureImageViewTag;
        self.accessoryView = view;
    }
}

- (void)setHighlightedDisclosureIndicatorImage:(UIImage*)image{
    [_highlightedDisclosureIndicatorImage release];
    _highlightedDisclosureIndicatorImage = [image retain];
    if([self.accessoryView tag] == DisclosureImageViewTag){
        UIImageView* view = (UIImageView*)self.accessoryView;
        view.highlightedImage = _highlightedDisclosureIndicatorImage;
    }
}

- (void)setCheckMarkImage:(UIImage*)img{
    [_checkMarkImage release];
    _checkMarkImage = [img retain];
    if(self.accessoryType == UITableViewCellAccessoryCheckmark){
        UIImageView* view = [[[UIImageView alloc]initWithImage:_checkMarkImage]autorelease];
        view.highlightedImage = _highlightedCheckMarkImage;
        view.tag = CheckmarkImageViewTag;
        self.accessoryView = view;
    }
}

- (void)setHighlightedCheckMarkImage:(UIImage*)image{
    [_highlightedCheckMarkImage release];
    _highlightedCheckMarkImage = [image retain];
    if([self.accessoryView tag] == CheckmarkImageViewTag){
        UIImageView* view = (UIImageView*)self.accessoryView;
        view.highlightedImage = _highlightedCheckMarkImage;
    }
}

- (void)setDisclosureButton:(UIButton*)button{
    [_disclosureButton release];
    _disclosureButton = [button retain];
    if(self.accessoryType == UITableViewCellAccessoryDetailDisclosureButton){
        self.accessoryView = _disclosureButton;
    }
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)theAccessoryType{
    bool shouldRemoveAccessoryView = (self.accessoryType != theAccessoryType) && (
                                                                                  (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator && _disclosureIndicatorImage)
                                                                                  ||(self.accessoryType == UITableViewCellAccessoryDetailDisclosureButton && _disclosureButton)
                                                                                  ||(self.accessoryType == UITableViewCellAccessoryCheckmark && _checkMarkImage));
    
    if(shouldRemoveAccessoryView){
        self.accessoryView = nil;
    }
    
    switch (theAccessoryType) {
        case UITableViewCellAccessoryDisclosureIndicator:{
            if(_disclosureIndicatorImage){
                UIImageView* view = (UIImageView*)[self viewWithTag:DisclosureImageViewTag];
                if(!view){
                    view = [[[UIImageView alloc]init]autorelease];
                    view.tag = DisclosureImageViewTag;
                }
                view.image = _disclosureIndicatorImage;
                view.highlightedImage = _highlightedDisclosureIndicatorImage;
                [view sizeToFit];
                self.accessoryView = view;
            }
            break;
        }
        case UITableViewCellAccessoryDetailDisclosureButton:{
            if(_disclosureButton){
                self.accessoryView = _disclosureButton;
            }
            break;        }
        case UITableViewCellAccessoryCheckmark:{
            if(_checkMarkImage){
                UIImageView* view = (UIImageView*)[self viewWithTag:DisclosureImageViewTag];
                if(!view){
                    view = [[[UIImageView alloc]init]autorelease];
                    view.tag = DisclosureImageViewTag;
                }
                view.image = _checkMarkImage;
                view.highlightedImage = _highlightedCheckMarkImage;
                [view sizeToFit];
                self.accessoryView = view;
            }
            break;
        }
    }
    
    [super setAccessoryType:theAccessoryType];
}

- (void)setHighlighted:(BOOL)highlighted{
    //[self willChangeValueForKey:@"highlighted"];
    [super setHighlighted:highlighted];
    //[self didChangeValueForKey:@"highlighted"];
    
    if(highlighted && self.selectionStyle != UITableViewCellSelectionStyleNone){
        //Push on top of the render stack
        UIView* s = [self superview];
        if([s isKindOfClass:[UITableView class]]){
            UITableViewCell* lastCell = nil;
            for(NSInteger i = [[s subviews]count] - 1; i >= 0; --i){
                UIView* v = [[s subviews]objectAtIndex:i];
                if([v isKindOfClass:[UITableViewCell class]]){
                    lastCell = (UITableViewCell*)v;
                    break;
                }
            }
            if(lastCell != self){
                [self removeFromSuperview];
                [s insertSubview:self aboveSubview:lastCell];
            }
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self willChangeValueForKey:@"highlighted"];
    [super setHighlighted:highlighted animated:animated];
    [self didChangeValueForKey:@"highlighted"];
    
    //if (self.delegate.wantFlatHierarchy)
    //    [self.delegate flattenHierarchyHighlighted:highlighted];
    
    if(highlighted && self.selectionStyle != UITableViewCellSelectionStyleNone){
        //Push on top of the render stack
        UIView* s = [self superview];
        if([s isKindOfClass:[UITableView class]]){
            UITableViewCell* lastCell = nil;
            for(NSInteger i = [[s subviews]count] - 1; i >= 0; --i){
                UIView* v = [[s subviews]objectAtIndex:i];
                if([v isKindOfClass:[UITableViewCell class]]){
                    lastCell = (UITableViewCell*)v;
                    break;
                }
            }
            if(lastCell != self){
                [self removeFromSuperview];
                [s insertSubview:self aboveSubview:lastCell];
            }
        }
    }
}


@end