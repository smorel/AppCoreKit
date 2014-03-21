//
//  UINavigationBar+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UINavigationBar+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "UIView+Style.h"
#import "CKConfiguration.h"

#import "CKVersion.h"
#import "UIImage+Transformations.h"


@implementation UINavigationBar (CKStyleManager)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
    UINavigationBar* navBar = (UINavigationBar*)view;
    if([CKOSVersion() floatValue] < 5){ 
        if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
            for(UINavigationItem* item in navBar.items){
                NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
                [item applySubViewsStyle:itemStyle appliedStack:appliedStack delegate:delegate];
            }
            return YES;
        }
    }
    else if([CKOSVersion() floatValue] < 7){
        if([appliedStack containsObject:view] == NO){
            if(style){
                if([style containsObjectForKey:CKStyleBackgroundImage]){
                    UIImage* image = [style backgroundImage];
                    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
                }
                [appliedStack addObject:view];
                [view applySubViewsStyle:style appliedStack:appliedStack delegate:delegate];
                return YES;
            }
        }
    }else{
        #ifdef ENABLE_XCODE5
        if([appliedStack containsObject:view] == NO){
            if(style){
                if([style containsObjectForKey:CKStyleBackgroundImage]){
                    UIImage* image = [style backgroundImage];
                    [navBar setBackgroundImage:image forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
                    if([CKOSVersion() floatValue] >= 6){
                        [navBar setShadowImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(navBar.bounds.size.width, 1)]];
                    }
                }
                [appliedStack addObject:view];
                [view applySubViewsStyle:style appliedStack:appliedStack delegate:delegate];
                return YES;
            }
        }
        #endif
    }
	return NO;
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    if([CKOSVersion() floatValue] < 5){
        BOOL hasBackgroundGradientView = [[self subviews]count] > 0 && [[[self subviews]objectAtIndex:0]isKindOfClass:[CKStyleView class]];
        [super insertSubview:view atIndex:hasBackgroundGradientView ? index + 1 : index];
        return;
    }
    [super insertSubview:view atIndex:index];
}

@end
