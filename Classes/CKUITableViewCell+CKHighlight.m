//
//  UITableViewCell+CKHighlight.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUITableViewCell+CKHighlight.h"
#import "CKRuntime.h"
#import "CKVersion.h"
#import <MapKit/MapKit.h>

@implementation UITableViewCell (CKHighlight)

+ (void)setView:(UIView*)theView highlighted:(BOOL)highlighted animated:(BOOL)animated{
    //FIXME : find a better way to manage exceptions for this behavior
    BOOL isTable = [theView isKindOfClass:[UITableView class]];
    BOOL isMap = [theView isKindOfClass:[MKMapView class]];
    BOOL isButton = [theView isKindOfClass:[UIButton class]];
    if( !(isTable || isMap || isButton) ){
        for(UIView* subView in theView.subviews){
            [UITableViewCell setView:subView highlighted:highlighted animated:animated];
        }
    }
    else if( isButton ){
        UIButton* bu = (UIButton*)theView;
        [bu setHighlighted:NO];
    }
}

- (void)ckSetHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [self ckSetHighlighted:highlighted animated:animated];
    if(self.selectionStyle != UITableViewCellSelectionStyleNone){
        for(UIView* subView in self.subviews){
            [UITableViewCell setView:subView highlighted:highlighted animated:animated];
        }
    }
}

+ (void)load{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //if([CKOSVersion() floatValue] >= 5.0){
        CKSwizzleSelector([UITableViewCell class],@selector(setHighlighted:animated:),@selector(ckSetHighlighted:animated:));
    //}
    [pool release];
}

@end
