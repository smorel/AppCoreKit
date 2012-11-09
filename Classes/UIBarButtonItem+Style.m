//
//  UIBarButtonItem+Style.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "UIBarButtonItem+Style.h"
#import "CKStyleManager.h"
#import "CKStyle+Parsing.h"
#import "UIView+Style.h"
#import "NSObject+Bindings.h"

@implementation CKBarButtonItemButton
@synthesize barButtonItem = _barButtonItem;

- (void)dealloc{
    [self clearBindingsContext];
    _barButtonItem = nil;
    [super dealloc];
}

- (void)update{
    [self setTitle:self.barButtonItem.title forState:UIControlStateNormal];

    if(self.barButtonItem.image){
        [self setImage:self.barButtonItem.image forState:UIControlStateNormal];
    }
    [self addTarget:self.barButtonItem.target action:self.barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
    self.enabled = self.barButtonItem.enabled;
    
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    [self sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,MAX(width,self.frame.size.width),MAX(height,self.frame.size.height));
}

- (id)initWithBarButtonItem:(UIBarButtonItem*)theBarButtonItem{
    self = [super init];
    self.barButtonItem = theBarButtonItem;
    [self update];
    
    theBarButtonItem.customView = self;
    
    [self beginBindingsContextByRemovingPreviousBindings];
    [theBarButtonItem bind:@"title" target:self action:@selector(update)];
    [theBarButtonItem bind:@"image" target:self action:@selector(update)];
    [theBarButtonItem bind:@"target" target:self action:@selector(update)];
    [theBarButtonItem bind:@"action" target:self action:@selector(update)];
    [theBarButtonItem bind:@"enabled" target:self action:@selector(update)];
    [self endBindingsContext];
    
    return self;
}

@end

@implementation UIBarButtonItem (CKStyle)

+ (BOOL)applyStyle:(NSMutableDictionary*)style toObject:(id)object appliedStack:(NSMutableSet*)appliedStack  delegate:(id)delegate{
    UIBarButtonItem* barButtonItem = (UIBarButtonItem*)object;
    BOOL systemButton = [[barButtonItem valueForKey:@"isSystemItem"]boolValue];
    
    if(!systemButton && style && [style isEmpty] == NO){
        [barButtonItem setAppliedStyle:style];
        
        UIButton* button = nil;
        if(barButtonItem.customView == nil || [[[barButtonItem.customView class]description]isEqualToString:@"UINavigationButton"]){
            button = [[[CKBarButtonItemButton alloc]initWithBarButtonItem:barButtonItem]autorelease];
        }
        else if([barButtonItem.customView isKindOfClass:[CKBarButtonItemButton class]]){
            button = (UIButton*)barButtonItem.customView;
        }
        
        if(button){
            if([style containsObjectForKey:@"title"]){
                barButtonItem.title = [style objectForKey:@"title"];
                [button setTitle:[style objectForKey:@"title"] forState:UIControlStateNormal];
            }
            
            if([UIButton applyStyle:style toView:button appliedStack:appliedStack delegate:delegate]){
                return YES;
            }
        }
        else if([NSObject applyStyle:style toObject:object appliedStack:appliedStack delegate:delegate]){
            return YES;
        }
    }
	else if([NSObject applyStyle:style toObject:object appliedStack:appliedStack delegate:delegate]){
        return YES;
	}
	return NO;
}

@end
