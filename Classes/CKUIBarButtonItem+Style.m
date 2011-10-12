//
//  CKUIBarButtonItem+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-11.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIBarButtonItem+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKUIView+Style.h"


@implementation UIBarButtonItem (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toObject:(id)object appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
    UIBarButtonItem* barButtonItem = (UIBarButtonItem*)object;
    
    if([style isEmpty] == NO && barButtonItem.customView == nil){
        UIButton* button = [[[UIButton alloc]initWithFrame:CGRectMake(0,0,barButtonItem.width,33)]autorelease];
        
        [button setTitle:barButtonItem.title forState:UIControlStateNormal];
        [button setImage:barButtonItem.image forState:UIControlStateNormal];
        [button addTarget:barButtonItem.target action:barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        
        barButtonItem.customView = button;
        if([UIButton applyStyle:style toView:button appliedStack:appliedStack delegate:delegate]){
            return YES;
        }
    }
	else if([NSObject applyStyle:style toObject:object appliedStack:appliedStack delegate:delegate]){
        return YES;
	}
	return NO;
}

@end
