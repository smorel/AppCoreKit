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
#import "CKVersion.h"
#import "CKRuntime.h"


@implementation UIToolbar (CKStyleManager)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toView:(UIView*)view appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
    UIToolbar* toolbar = (UIToolbar*)view;
    if([CKOSVersion() floatValue] < 5){ 
        if([UIView applyStyle:style toView:view appliedStack:appliedStack delegate:delegate]){
            for(UIBarButtonItem* item in toolbar.items){
                NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
                [item applyStyle:itemStyle];
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
                [[self class] applyStyleByIntrospection:style toObject:self appliedStack:appliedStack delegate:delegate];
                [appliedStack addObject:view];
                
                [view setAppliedStyle:style];
                
                for(UIBarButtonItem* item in toolbar.items){
                    NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
                    [item applyStyle:itemStyle];
                }
                
                
                //[view applySubViewsStyle:style appliedStack:appliedStack delegate:delegate];
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


- (void)UIToolbar_CKStyleManager_setItems:(NSArray *)items{
    [self UIToolbar_CKStyleManager_setItems:items];
    
    NSMutableDictionary* style = [self appliedStyle];
    if(style){
        for(UIBarButtonItem* item in items){
            NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
            [item applyStyle:itemStyle];
        }
    }
}

- (void)UIToolbar_CKStyleManager_setItems:(NSArray *)items animated:(BOOL)animated{
    [self UIToolbar_CKStyleManager_setItems:items animated:animated];
    
    NSMutableDictionary* style = [self appliedStyle];
    if(style){
        for(UIBarButtonItem* item in items){
            NSMutableDictionary* itemStyle = [style styleForObject:item propertyName:nil];
            [item applyStyle:itemStyle];
        }
    }
}

@end



bool swizzle_UIToolbar_CKStyleManager(){
    CKSwizzleSelector([UIToolbar class],@selector(setItems:),@selector(UIToolbar_CKStyleManager_setItems:));
    CKSwizzleSelector([UIToolbar class],@selector(setItems:animated:),@selector(UIToolbar_CKStyleManager_setItems:animated:));
    return 1;
}

static bool bo_swizzle_UIToolbar_CKStyleManager = swizzle_UIToolbar_CKStyleManager();