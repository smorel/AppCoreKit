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
#import "CKNSObject+Bindings.h"

@interface CKBarButtonItemButton : UIButton
@property (nonatomic,assign)UIBarButtonItem* barButtonItem;
- (id)initWithBarButtonItem:(UIBarButtonItem*)barButtonItem;

@end

@implementation CKBarButtonItemButton
@synthesize barButtonItem = _barButtonItem;

- (void)dealloc{
    [self clearBindingsContext];
    _barButtonItem = nil;
    [super dealloc];
}

- (void)update{
    [self setTitle:self.barButtonItem.title forState:UIControlStateNormal];
    [self setImage:self.barButtonItem.image forState:UIControlStateNormal];
    [self addTarget:self.barButtonItem.target action:self.barButtonItem.action forControlEvents:UIControlEventTouchUpInside];
    self.enabled = self.barButtonItem.enabled;
    
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    [self sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,MAX(width,self.frame.size.width),height);
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
    
    if([style isEmpty] == NO && barButtonItem.customView == nil){
        UIButton* button = [[[CKBarButtonItemButton alloc]initWithBarButtonItem:barButtonItem]autorelease];
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
