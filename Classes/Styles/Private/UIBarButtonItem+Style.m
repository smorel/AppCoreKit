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
#import "CKWeakRef.h"

@interface CKBarButtonItemButton()
@property(nonatomic,retain) CKWeakRef* barButtonItemWeakRef;
@property(nonatomic,assign) BOOL observing;
@end

@implementation CKBarButtonItemButton
@synthesize barButtonItem = _barButtonItem;
@synthesize barButtonItemWeakRef = _barButtonItemWeakRef;

- (void)setBarButtonItem:(UIBarButtonItem *)barButtonItem{
    __block CKBarButtonItemButton* bself = self;
    self.barButtonItemWeakRef = [CKWeakRef weakRefWithObject:barButtonItem block:^(CKWeakRef *weakRef) {
        if(bself.observing){
            [weakRef.object removeObserver:bself forKeyPath:@"title"];
            [weakRef.object removeObserver:bself forKeyPath:@"image"];
            [weakRef.object removeObserver:bself forKeyPath:@"enabled"];
            bself.observing = NO;
        }
    }];
}

- (UIBarButtonItem*)barButtonItem{
    return self.barButtonItemWeakRef.object;
}

- (void)dealloc{
    if(self.observing){
        [self.barButtonItem removeObserver:self forKeyPath:@"title"];
        [self.barButtonItem removeObserver:self forKeyPath:@"image"];
        [self.barButtonItem removeObserver:self forKeyPath:@"enabled"];
        self.observing = NO;
    }
    [_barButtonItemWeakRef autorelease];
    _barButtonItemWeakRef = nil;
    [super dealloc];
}

- (void)update{
    [self setTitle:self.barButtonItem.title forState:UIControlStateNormal];

    if(self.barButtonItem.image){
        [self setImage:self.barButtonItem.image forState:UIControlStateNormal];
    }
    [self addTarget:self action:@selector(execute:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.observing = YES;
    
    theBarButtonItem.customView = self;
    
    [theBarButtonItem addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [theBarButtonItem addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [theBarButtonItem addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    [self update];
}

- (void)execute:(id)sender{
    if(self.barButtonItem.target && self.barButtonItem.action){
        [self.barButtonItem.target performSelector:self.barButtonItem.action withObject:sender];
    }
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
