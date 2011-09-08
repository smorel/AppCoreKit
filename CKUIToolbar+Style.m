//
//  CKUIToolbar+Style.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-09-07.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKUIToolbar+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "CKUIView+Style.h"


@implementation UIToolbar (CKStyleManager)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
	if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
        UIToolbar* toolbar = (UIToolbar*)view;
        for(UIBarButtonItem* item in toolbar.items){
            NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
            [item applySubViewsStyle:itemStyle appliedStack:appliedStack delegate:delegate];
        }
        return YES;
	}
	return NO;
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
    BOOL hasBackgroundGradientView = [[self subviews]count] > 0 && [[[self subviews]objectAtIndex:0]isKindOfClass:[CKGradientView class]];
    [super insertSubview:view atIndex:hasBackgroundGradientView ? index + 1 : index];
}

@end
