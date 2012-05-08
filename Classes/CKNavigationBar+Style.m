//
//  CKNavigationBar+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-07.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKNavigationBar+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKUIView+Style.h"

#import "CKVersion.h"


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
    else{
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
