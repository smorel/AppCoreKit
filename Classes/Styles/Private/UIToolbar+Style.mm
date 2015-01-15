//
//  UIToolbar+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIToolbar+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "UIView+Style.h"
#import "CKVersion.h"
#import "CKRuntime.h"
#import "UIBarButtonItem+Style.h"


@implementation UIToolbar (CKStyleManager)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
    UIToolbar* toolbar = (UIToolbar*)view;
    if([CKOSVersion() floatValue] < 5){ 
        if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
            for(UIBarButtonItem* item in toolbar.items){
                NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
                [[item class] applyStyle:itemStyle toObject:item appliedStack:appliedStack delegate:nil];
                
                if([CKOSVersion() floatValue] < 4.2){
                    //Handle this manually here as there is a bug in the framework for versions < 4.2
                    if([item.customView isKindOfClass:[CKBarButtonItemButton class]]){
                        [toolbar addSubview:item.customView];
                    }
                }
            }
            return YES;
        }
    }
    else{
        if([appliedStack containsObject:view] == NO){
            if(style){
                if([style containsObjectForKey:CKStyleBackgroundImage]){
                    UIImage* image = [style backgroundImage];
                    [toolbar setBackgroundImage:image forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
                }
                [[self class] applyStyleByIntrospection:style toObject:view appliedStack:appliedStack delegate:delegate];
                [appliedStack addObject:view];
                
                [view setAppliedStyle:style];
                
                for(UIBarButtonItem* item in toolbar.items){
                    NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
                    
                    [[item class] applyStyle:itemStyle toObject:item appliedStack:appliedStack delegate:nil];
                }
                
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
