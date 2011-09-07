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


@implementation UINavigationBar (CKStyleManager)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
        UINavigationBar* navBar = (UINavigationBar*)view;
        for(UINavigationItem* item in navBar.items){
            NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
            [item applySubViewsStyle:itemStyle appliedStack:appliedStack delegate:delegate];
            /*if(item.leftBarButtonItem){
                NSMutableDictionary* barItemStyle = [itemStyle styleForObject:item.leftBarButtonItem propertyName:nil];
                [item.leftBarButtonItem applySubViewsStyle:barItemStyle appliedStack:appliedStack delegate:delegate];
            }
            if(item.rightBarButtonItem){
                NSMutableDictionary* barItemStyle = [itemStyle styleForObject:item.rightBarButtonItem propertyName:nil];
                [item.rightBarButtonItem applySubViewsStyle:barItemStyle appliedStack:appliedStack delegate:delegate];
            }*/
        }
        return YES;
	}
	return NO;
}

@end
