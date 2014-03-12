//
//  CKLayoutDescription.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/18/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKLayoutDescription.h"
#import <objc/runtime.h>
#import "CKLayoutViewProxy.h"


#import "UIView+CKLayout.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "CKPropertyExtendedAttributes.h"
#import "CKStyleManager.h"
#import "CKRuntime.h"
#import "UIView+Name.h"
#import "CKStyleView.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+Style.h"



@interface CKLayoutViewProxy()
@property(nonatomic,retain,readwrite) UIView* view;
- (void)setupViewAttributes;
@end

@implementation CKLayoutDescription

- (void)dealloc{
    [_name release];
    [_layoutBoxes release];
    [_viewAttributes release];
    [super dealloc];
}

- (id)init{
    self = [super init];
    self.layoutBoxes = [CKArrayCollection collection];
    return self;
}

@end

static char UIViewMultiLayoutDescriptionsKey;
static char UIViewMultiLayoutCurrentLayoutKey;

@implementation UIView(CKMultiLayout)
@dynamic layoutDescriptions, currentLayout;

- (void)layoutDescriptionsExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.contentType = [CKLayoutDescription class];
}

- (void)setLayoutDescriptions:(CKArrayCollection *)layoutDescriptions{
    objc_setAssociatedObject(self,
                             &UIViewMultiLayoutDescriptionsKey,
                             layoutDescriptions,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKArrayCollection*)layoutDescriptions{
   CKArrayCollection* c = objc_getAssociatedObject(self, &UIViewMultiLayoutDescriptionsKey);
    if(!c){
        c = [CKArrayCollection collection];
        [self setLayoutDescriptions:c];
    }
    
    return c;
}

- (void)setCurrentLayout:(CKLayoutDescription *)currentLayout{
    objc_setAssociatedObject(self,
                             &UIViewMultiLayoutCurrentLayoutKey,
                             currentLayout,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKLayoutDescription*)currentLayout{
    return objc_getAssociatedObject(self, &UIViewMultiLayoutCurrentLayoutKey);
}


- (CKLayoutDescription*)layoutDescriptionNamed:(NSString*)name{
    for(CKLayoutDescription* description in self.layoutDescriptions){
        if([description.name isEqualToString:name])
            return description;
    }
    return nil;
}

- (void)setLayoutNamed:(NSString*)name animated:(BOOL)animated completion:(void(^)())completion{
    CKLayoutDescription* description = [self layoutDescriptionNamed:name];
    [self setLayout:description animated:animated completion:completion];
}

- (void)appendSubViewsToSet:(NSMutableSet*)set{
    [set addObject:self];
    
    for(UIView* v in self.subviews){
        [v appendSubViewsToSet:set];
    }
}

+ (void)appendSubViewNameInLayoutBoxes:(NSArray*)boxes toSet:(NSMutableSet*)set{
    for(NSObject<CKLayoutBoxProtocol>* box in boxes){
        if(box.name){
            if([box isKindOfClass:[UIView class]] || [box isKindOfClass:[CKLayoutViewProxy class]] ){
                [set addObject:box.name];
            }
        }
        [UIView appendSubViewNameInLayoutBoxes:[box.layoutBoxes allObjects] toSet:set];
    }
}

- (void)computeSubviewsDiffFromLayoutBoxes:(NSArray*)boxes hide:(NSMutableSet*)hide show:(NSMutableSet*)show move:(NSMutableSet*)move{
    NSMutableSet* nameOfVisibleViews = [NSMutableSet set];
    [UIView appendSubViewNameInLayoutBoxes:boxes toSet:nameOfVisibleViews];
    
    NSMutableSet* currentSubviews = [NSMutableSet set];
    [self appendSubViewsToSet:currentSubviews];
    
    for(UIView* v in currentSubviews){
        if(!v.name || v == self)
            continue;
        
        BOOL visible = NO;
        UIView* currentView = v;
        while(currentView && !visible){
            visible = visible || [nameOfVisibleViews containsObject:currentView.name];
            currentView = [currentView superview];
        }
        
        if(visible){
            if(v.alpha <= 0){
                [show addObject:v.name];
            }else{
                [move addObject:v.name];
            }
        }else{
            [hide addObject:v.name];
        }
    }
}

- (void)setLayout:(CKLayoutDescription*)layoutDescription animated:(BOOL)animated completion:(void(^)())completion{
    if(self.currentLayout == layoutDescription){
        return;
    }
    
    NSMutableSet* hide = [NSMutableSet set];
    NSMutableSet* show = [NSMutableSet set];
    NSMutableSet* move = [NSMutableSet set];
    
    [self computeSubviewsDiffFromLayoutBoxes:[layoutDescription.layoutBoxes allObjects] hide:hide show:show move:move];
    
    [UIView invalidateLayoutViewProxiesInLayoutBoxes:[self.currentLayout.layoutBoxes allObjects]];
    
    BOOL animate = (animated && self.currentLayout != nil);
    
    [self setLayoutBoxes:layoutDescription.layoutBoxes];
    
    if(animate){
        [UIView animateWithDuration: .3 animations:^{
            for(NSString* name in hide){
                UIView* v = [self viewWithName:name];
                v.alpha = 0;
            }
            [UIView setupViewAttributesFromLayoutDescription:layoutDescription inView:self];
            [UIView setupViewProxiesAttributesInLayoutBoxes:[layoutDescription.layoutBoxes allObjects]];
            [self layoutSubviews];
        }
        completion:^(BOOL finished) {
                [UIView animateWithDuration:.3  animations:^{
                    for(NSString* name in show){
                            UIView* v = [self viewWithName:name];
                            v.alpha = 1;
                    }
                }completion:^(BOOL finished) {
                    if(completion){
                        completion();
                }
                }];
        }];
    }else{
        for(NSString* name in hide){
            UIView* v = [self viewWithName:name];
            v.alpha = 0;
        }
        for(NSString* name in show){
            UIView* v = [self viewWithName:name];
            v.alpha = 1;
        }
        [UIView setupViewAttributesFromLayoutDescription:layoutDescription inView:self];
        [UIView setupViewProxiesAttributesInLayoutBoxes:[layoutDescription.layoutBoxes allObjects]];
        [self layoutSubviews];
    }
    
    self.currentLayout = layoutDescription;
}

+ (void)setupViewAttributesFromLayoutDescription:(CKLayoutDescription*)description inView:(UIView*)view{
    if(view && description.viewAttributes){
        [NSValueTransformer transform:description.viewAttributes toObject:view];
    }
}

+ (void)setupViewProxiesAttributesInLayoutBoxes:(NSArray*)boxes{
    if(!boxes)
        return;
    
    for(NSObject<CKLayoutBoxProtocol>* box in boxes){
        if(box.name){
            if([box isKindOfClass:[CKLayoutViewProxy class]] ){
                CKLayoutViewProxy* proxy = (CKLayoutViewProxy*)box;
                [proxy setupViewAttributes];
            }
        }
        [UIView setupViewProxiesAttributesInLayoutBoxes:[box.layoutBoxes allObjects]];
    }
}

+ (void)invalidateLayoutViewProxiesInLayoutBoxes:(NSArray*)boxes{
    if(!boxes)
        return;
    
    for(NSObject<CKLayoutBoxProtocol>* box in boxes){
        if(box.name){
            if([box isKindOfClass:[CKLayoutViewProxy class]] ){
                CKLayoutViewProxy* proxy = (CKLayoutViewProxy*)box;
                if(proxy.view){
                    //Moves the view into the root view so that the next layout will be able to grab it if necessary
                    [box.rootLayoutBox.containerLayoutView insertSubview:proxy.view atIndex:0];
                    proxy.view = nil;
                }
            }
        }
        [UIView invalidateLayoutViewProxiesInLayoutBoxes:[box.layoutBoxes allObjects]];
    }
}


@end
