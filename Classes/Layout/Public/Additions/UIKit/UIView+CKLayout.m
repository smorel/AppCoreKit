//
//  UIView+CKLayout.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

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


@interface CKLayoutBox()

+ (CGSize)preferredSizeConstraintToSize:(CGSize)size forBox:(NSObject<CKLayoutBoxProtocol>*)box;
- (NSObject<CKLayoutBoxProtocol>*)previousVisibleBoxFromIndex:(NSInteger)index;
+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly;
+ (void)performLayoutWithFrame:(CGRect)theframe forBox:(NSObject<CKLayoutBoxProtocol>*)box;
+ (void)addLayoutBoxes:(NSArray*)boxes toBox:(NSObject<CKLayoutBoxProtocol>*)box;
+ (void)removeViewsFromBox:(NSObject<CKLayoutBoxProtocol>*)box recursively:(BOOL)recursively;
+ (void)removeLayoutBoxes:(NSArray*)boxes fromBox:(NSObject<CKLayoutBoxProtocol>*)box;
+ (void)initializeBox:(NSObject<CKLayoutBoxProtocol>*)box;

@end

@implementation UIView (CKLayout)

//TODO : Implements setter/getter for all properties and invalidate layout

@dynamic  maximumSize, minimumSize, margins, padding, layoutBoxes,frame,containerLayoutBox,containerLayoutView,fixedSize,hidden,
maximumWidth,maximumHeight,minimumWidth,minimumHeight,fixedWidth,fixedHeight,marginLeft,marginTop,marginBottom,marginRight,paddingLeft,paddingTop,paddingBottom,paddingRight,
lastComputedSize,lastPreferedSize,invalidatedLayoutBlock,flexibleSize,name,containerViewController;

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    if(CGSizeEqualToSize(size, self.lastComputedSize))
        return self.lastPreferedSize;
    self.lastComputedSize = size;
    
    if(self.layoutBoxes && [self.layoutBoxes count] > 0){
        CGFloat maxWidth = 0;
        CGFloat maxHeight = 0;
        
        size.width -= self.padding.left + self.padding.right;
        size.height -= self.padding.top + self.padding.bottom;
        
        for(NSObject<CKLayoutBoxProtocol>* box in self.layoutBoxes){
            CGSize constraint = size;
            
            CGSize s = [box preferredSizeConstraintToSize:constraint];
            
            if(s.width > maxWidth && s.width < MAXFLOAT)   maxWidth = s.width;
            if(s.height > maxHeight && s.height < MAXFLOAT) maxHeight = s.height;
        }
        
        size = CGSizeMake(maxWidth,maxHeight);
        
        size.width += self.padding.left + self.padding.right;
        size.height += self.padding.top + self.padding.bottom;
    }else{
        if([self isKindOfClass:[UIControl class]] || [self isKindOfClass:[UIProgressView class]]){
            size.width -= self.padding.left + self.padding.right;
            size.height -= self.padding.top + self.padding.bottom;
            
            size = [self sizeThatFits:size];
            
            size.width += self.padding.left + self.padding.right;
            size.height += self.padding.top + self.padding.bottom;
        }
    }
    
    if(size.width >= MAXFLOAT){
        size.width = 0;
    }
    if(size.height >= MAXFLOAT){
        size.height = 0;
    }
    
    size = [CKLayoutBox preferredSizeConstraintToSize:size forBox:self];
    size = CGSizeMake(ceilf(size.width - (self.padding.left + self.padding.right)), ceilf(size.height - (self.padding.top + self.padding.bottom)));
    
    self.lastPreferedSize = CGSizeMake(size.width + self.padding.left + self.padding.right,size.height + self.padding.top + self.padding.bottom);
    return self.lastPreferedSize;
}

- (void)performLayoutWithFrame:(CGRect)theframe{
    CGSize constraint = theframe.size;
    if(!self.flexibleSize && self.containerLayoutBox == nil && self.layoutBoxes && [self.layoutBoxes count] > 0){
        constraint.height = MAXFLOAT;
    }
    
    CGSize lastComputedSize = self.lastPreferedSize;
    CGSize size = [self preferredSizeConstraintToSize:constraint];
    
    //We hitted a special case in navigation bar subviews. Especially titleView
    //We possibly try to set a frame in this method that will trigger setNeedsLayout on the navigation bar.
    //At the next frame, the navigation bar will compute its own layoutSubviews and will crop the title view
    //for it to fit between left and right items and call layoutsubviews on the titleview again
    //And if we still try to set a higher width as the layout tells us, it creates a loop ...
    //That's why we handle that case like this.
    //Which means, if we already computed the layout for this title view, we'll already have a preferedSize set.
    //If the content do not change, the prefered size computed here and the last prefered size will be equals.
    //that means we do not need to set the frame of this view again like that the navigation bar will not
    //get its layout invalidated !
    
    BOOL skipFrameSetAsNavigationBarSubView = false;
    if([[self superview]isKindOfClass:[UINavigationBar class]]){
        if(CGSizeEqualToSize(lastComputedSize,size)){
            skipFrameSetAsNavigationBarSubView = YES;
        }
        
    }
    
    CGRect frame = CGRectMake(theframe.origin.x,theframe.origin.y,size.width,size.height);
    
    CGRect subBoxesFrame = frame;
    
    //If the view has its own layout, the sub boxes are placed relative to it !
    if([self containerLayoutBox] == [self superview] || (self.layoutBoxes && [self.layoutBoxes count] > 0)){
        subBoxesFrame = CGRectMake(0,0,frame.size.width,frame.size.height);
    }
    
    //Apply padding
    subBoxesFrame = CGRectMake(subBoxesFrame.origin.x + self.padding.left,
                               subBoxesFrame.origin.y + self.padding.top,
                               subBoxesFrame.size.width - (self.padding.left + self.padding.right),
                               subBoxesFrame.size.height - (self.padding.top + self.padding.bottom));
    
    [CKLayoutBox performLayoutWithFrame:subBoxesFrame forBox:self];
    
    if(!skipFrameSetAsNavigationBarSubView && !self.flexibleSize && self.containerLayoutBox == nil && self.layoutBoxes && [self.layoutBoxes count] > 0){
        CGSize boundingBox = CGSizeMake(0, 0);
        for(NSObject<CKLayoutBoxProtocol>* subbox in self.layoutBoxes){
            if((subbox.frame.origin.x + subbox.frame.size.width) > boundingBox.width){
                boundingBox.width = subbox.frame.origin.x + subbox.frame.size.width;
            }
            if((subbox.frame.origin.y + subbox.frame.size.height) > boundingBox.height){
                boundingBox.height = subbox.frame.origin.y + subbox.frame.size.height;
            }
        }
        
        CGRect newFrame = CGRectMake(self.frame.origin.x,self.frame.origin.y,boundingBox.width + (self.padding.left + self.padding.right),boundingBox.height + (self.padding.top + self.padding.bottom));
        CGRect oldFrame = self.frame;
        [self setBoxFrameTakingCareOfTransform:newFrame];
        
        if(!CGSizeEqualToSize(newFrame.size, oldFrame.size) && [[self superview]isKindOfClass:[UITableView class]]){
            //tableheaderview || tablefooterview
            UITableView* superTable = (UITableView*)[self superview];
            if(superTable.tableHeaderView == self){
                superTable.tableHeaderView = nil;
                superTable.tableHeaderView = self;
            }
            if(superTable.tableFooterView == self){
                superTable.tableFooterView = nil;
                superTable.tableFooterView = self;
            }
        }
    }else if([self.containerLayoutBox isKindOfClass:[UIView class]]){
        [self setBoxFrameTakingCareOfTransform:frame];
    }
}

- (void)invalidateLayout{
    NSObject<CKLayoutBoxProtocol>* l = [self rootLayoutBox];
    if(l && !CGSizeEqualToSize(l.lastComputedSize, CGSizeMake(0,0))){
        [CKLayoutBox invalidateLayoutBox:l recursivelly:YES];
        [l.containerLayoutView setNeedsLayout];
        if(l.invalidatedLayoutBlock){
            l.invalidatedLayoutBlock(l);
        }
    }
}

- (NSObject<CKLayoutBoxProtocol>*)rootLayoutBox{
    NSObject<CKLayoutBoxProtocol>* l = self;
    while(l){
        if(l.containerLayoutBox){
            l = l.containerLayoutBox;
        }else return l;
    }
    return nil;
}

- (id<CKLayoutBoxProtocol>)_layoutWithNameInSelf:(NSString*)thename{
    for(id<CKLayoutBoxProtocol> layoutBox in self.layoutBoxes){
        if([[layoutBox name]isEqualToString:thename]){
            return layoutBox;
        }
    }
    return nil;
}

- (id<CKLayoutBoxProtocol>)layoutWithName:(NSString*)thename{
    id<CKLayoutBoxProtocol> layoutBox = [self _layoutWithNameInSelf:thename];
    if(layoutBox){
        return layoutBox;
    }
    
    for(id<CKLayoutBoxProtocol> layoutBox in self.layoutBoxes){
        id<CKLayoutBoxProtocol> subLayoutBox = [layoutBox layoutWithName:thename];
        if(subLayoutBox){
            return subLayoutBox;
        }
    }
    
    return nil;
}

- (id<CKLayoutBoxProtocol>)layoutWithKeyPath:(NSString*)keypath{
    id<CKLayoutBoxProtocol> currentBox = self;
    
    NSArray* components = [keypath componentsSeparatedByString:@"."];
    for(NSString* str in components){
        currentBox = [currentBox _layoutWithNameInSelf:str];
        if(!currentBox)
            return nil;
    }
    
    return currentBox;
}

- (void)setBoxFrameTakingCareOfTransform:(CGRect)rect{
    
    if( CGRectEqualToRect(self.frame, rect))
        return;
    
    //    rect = CGRectApplyAffineTransform(rect, self.transform);
    self.frame = rect;
    
    //self.bounds = CGRectMake(0,0,rect.size.width,rect.size.height);
    //self.center = CGPointMake(rect.origin.x + (rect.size.width / 2),rect.origin.y + (rect.size.height /2));
}


+ (id)inflateViewFromStyleWithId:(NSString*)styleId{
    return [self inflateViewFromStyleWithId:styleId fromStyleManager:[CKStyleManager defaultManager]];
}

+ (id)inflateViewFromStyleWithId:(NSString*)styleId fromStyleManager:(CKStyleManager*)styleManager{
    NSMutableDictionary* viewLayoutTemplate = [styleManager dictionaryForKey:styleId];
    
    Class c = [UIView class];
    if([viewLayoutTemplate containsObjectForKey:@"@class"]){
        c = NSClassFromString([viewLayoutTemplate objectForKey:@"@class"]);
        NSAssert([NSObject isClass:c kindOfClass:[UIView class]],@"the @class in style with id '%@' must specify a UIView subclass",styleId);
    }else{
        NSAssert(NO,@"Style with id '%@' must specify a @class attributes with a UIView subclass",styleId);
    }
    
    UIView* view = [[[c alloc]init]autorelease];
	[c applyStyle:viewLayoutTemplate toView:view appliedStack:[NSMutableSet set] delegate:nil];
    
    return view;
}

- (void)addLayoutBox:(id<CKLayoutBoxProtocol>)box{
    CKArrayCollection* mm = (CKArrayCollection*)[self layoutBoxes];
    if(!mm){
        self.layoutBoxes = [CKArrayCollection collection];
        mm = (CKArrayCollection*)[self layoutBoxes];
    }
    
    [mm addObject:box];
    
    [CKLayoutBox addLayoutBoxes:@[box] toBox:self];
    [self invalidateLayout];
}

- (void)insertLayoutBox:(id<CKLayoutBoxProtocol>)box atIndex:(NSInteger)index{
    CKArrayCollection* mm = (CKArrayCollection*)[self layoutBoxes];
    if(!mm){
        self.layoutBoxes = [CKArrayCollection collection];
        mm = (CKArrayCollection*)[self layoutBoxes];
    }
    
    [mm insertObject:box atIndex:index];
    
    [CKLayoutBox addLayoutBoxes:@[box] toBox:self];
    [self invalidateLayout];
    
}

- (void)removeLayoutBox:(id<CKLayoutBoxProtocol>)box{
    CKArrayCollection* mm = (CKArrayCollection*)[self layoutBoxes];
    [mm removeObject:box];
    
    [CKLayoutBox removeLayoutBoxes:@[box] fromBox:self];
    [self invalidateLayout];
}

- (void)removeAllLayoutBoxes{
    NSArray* boxes = [[self layoutBoxes]allObjects];
    [[self layoutBoxes]removeAllObjects];
    
    [CKLayoutBox removeLayoutBoxes:boxes fromBox:self];
    [self invalidateLayout];
}

+ (void)invalidateLayoutBox:(NSObject<CKLayoutBoxProtocol>*)box recursivelly:(BOOL)recursivelly{
    [CKLayoutBox invalidateLayoutBox:box recursivelly:recursivelly];
}

static char UIViewContainerViewControllerKey;
- (void)setContainerViewController:(UIViewController *)containerViewController{
    objc_setAssociatedObject(self, &UIViewContainerViewControllerKey, containerViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (UIViewController*)containerViewController{
    UIViewController* controller = objc_getAssociatedObject(self, &UIViewContainerViewControllerKey);
    if(!controller){
        if([self superview]){
            return [[self superview]containerViewController];
        }
    }
    return controller;
}

@end





static char UIViewMaximumSizeKey;
static char UIViewMinimumSizeKey;
static char UIViewMarginsKey;
static char UIViewPaddingKey;
static char UIViewLayoutBoxesKey;
static char UIViewContainerLayoutBoxKey;
static char UIViewLastComputedSizeKey;
static char UIViewLastPreferedSizeKey;
static char UIViewInvalidatedLayoutBlockKey;
static char UIViewFlexibleSizeKey;

@interface UIView (Layout_Private)
@end

@implementation UIView (Layout_Private)

- (void)setFlexibleSize:(BOOL)flexibleSize{
    objc_setAssociatedObject(self,
                             &UIViewFlexibleSizeKey,
                             [NSNumber numberWithBool:flexibleSize],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)flexibleSize{
    static Class c = nil;
    if(c == nil){
        c = NSClassFromString(@"UITableViewCellContentView");
    }
    
    if([self isKindOfClass:c]){
        return YES;
    }
    
    id value = objc_getAssociatedObject(self, &UIViewFlexibleSizeKey);
    return value ? [value boolValue] : ( [self isKindOfClass:[UIScrollView class]] ? YES : NO );
}

- (void)setInvalidatedLayoutBlock:(CKLayoutBoxInvalidatedBlock)invalidatedLayoutBlock{
    objc_setAssociatedObject(self,
                             &UIViewInvalidatedLayoutBlockKey,
                             [invalidatedLayoutBlock copy],
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CKLayoutBoxInvalidatedBlock)invalidatedLayoutBlock{
    return objc_getAssociatedObject(self, &UIViewInvalidatedLayoutBlockKey);
}

- (void)setFixedSize:(CGSize)size{
    self.maximumSize = size;
    self.minimumSize = size;
}

- (void)setLastComputedSize:(CGSize)s{
    objc_setAssociatedObject(self,
                             &UIViewLastComputedSizeKey,
                             [NSValue valueWithCGSize:s],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)lastComputedSize{
    id value = objc_getAssociatedObject(self, &UIViewLastComputedSizeKey);
    return value ? [value CGSizeValue] : CGSizeMake(0, 0);
}


- (void)setLastPreferedSize:(CGSize)s{
    objc_setAssociatedObject(self,
                             &UIViewLastPreferedSizeKey,
                             [NSValue valueWithCGSize:s],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)lastPreferedSize{
    id value = objc_getAssociatedObject(self, &UIViewLastPreferedSizeKey);
    return value ? [value CGSizeValue] : CGSizeMake(0, 0);
}



- (CGSize)fixedSize{
    if(CGSizeEqualToSize(self.maximumSize, self.minimumSize)){
        CGSize size = self.minimumSize;
        return size;
    }
    return CGSizeMake(MAXFLOAT, MAXFLOAT);
}

- (void)setMaximumSize:(CGSize)s{
    objc_setAssociatedObject(self,
                             &UIViewMaximumSizeKey,
                             [NSValue valueWithCGSize:s],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self invalidateLayout];
}

- (CGSize)maximumSize{
    id value = objc_getAssociatedObject(self, &UIViewMaximumSizeKey);
    CGSize size = value ? [value CGSizeValue] : CGSizeMake(0, 0);
    
    /*
     if(!CGSizeEqualToSize(size, CGSizeMake(0,0)) && !CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity)){
     CGRect rect = CGRectMake(0,0,size.width,size.height);
     rect = CGRectApplyAffineTransform(rect, self.transform);
     return rect.size;
     }*/
    return size;
}

- (void)setMinimumSize:(CGSize)s{
    objc_setAssociatedObject(self,
                             &UIViewMinimumSizeKey,
                             [NSValue valueWithCGSize:s],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self invalidateLayout];
}

- (CGSize)minimumSize{
    id value = objc_getAssociatedObject(self, &UIViewMinimumSizeKey);
    CGSize size = value ? [value CGSizeValue] : CGSizeMake(0, 0);
    
    /*
     if(!CGSizeEqualToSize(size, CGSizeMake(0,0)) &&  !CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity)){
     CGRect rect = CGRectMake(0,0,size.width,size.height);
     rect = CGRectApplyAffineTransform(rect, self.transform);
     return rect.size;
     }*/
    
    return size;
}

- (void)setMargins:(UIEdgeInsets)m{
    objc_setAssociatedObject(self,
                             &UIViewMarginsKey,
                             [NSValue valueWithUIEdgeInsets:m],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self invalidateLayout];
}

- (UIEdgeInsets)margins{
    id value = objc_getAssociatedObject(self, &UIViewMarginsKey);
    return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setPadding:(UIEdgeInsets)m{
    objc_setAssociatedObject(self,
                             &UIViewPaddingKey,
                             [NSValue valueWithUIEdgeInsets:m],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self invalidateLayout];
}

- (UIEdgeInsets)padding{
    id value = objc_getAssociatedObject(self, &UIViewPaddingKey);
    return value ? [value UIEdgeInsetsValue] : UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)setLayoutBoxes:(CKArrayCollection*)boxes{
    if(self.layoutBoxes){
        [CKLayoutBox removeLayoutBoxes:[self.layoutBoxes allObjects] fromBox:self];
    }
    
    objc_setAssociatedObject(self,
                             &UIViewLayoutBoxesKey,
                             boxes,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if(self.layoutBoxes){
        [CKLayoutBox addLayoutBoxes:[self.layoutBoxes allObjects] toBox:self];
    }
    
    [self invalidateLayout];
}

- (CKArrayCollection*)layoutBoxes{
    return objc_getAssociatedObject(self, &UIViewLayoutBoxesKey);
}

- (void)setContainerLayoutBox:(NSObject<CKLayoutBoxProtocol>*)c{
    objc_setAssociatedObject(self,
                             &UIViewContainerLayoutBoxKey,
                             c,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (NSObject<CKLayoutBoxProtocol>*)containerLayoutBox{
    return objc_getAssociatedObject(self, &UIViewContainerLayoutBoxKey);
}

- (UIView*)containerLayoutView{
    return self;
}

- (void)setMaximumWidth:(CGFloat)f  { self.maximumSize = CGSizeMake(f,self.maximumSize.height); }
- (void)setMaximumHeight:(CGFloat)f { self.maximumSize = CGSizeMake(self.maximumSize.width,f); }
- (void)setMinimumWidth:(CGFloat)f  { self.minimumSize = CGSizeMake(f,self.minimumSize.height); }
- (void)setMinimumHeight:(CGFloat)f { self.minimumSize = CGSizeMake(self.minimumSize.width,f); }
- (void)setFixedWidth:(CGFloat)f    { self.maximumWidth = f; self.minimumWidth = f; }
- (void)setFixedHeight:(CGFloat)f   { self.maximumHeight = f; self.minimumHeight = f; }
- (void)setMarginLeft:(CGFloat)f    { UIEdgeInsets insets = self.margins; insets.left = f; self.margins = insets; }
- (void)setMarginTop:(CGFloat)f     { UIEdgeInsets insets = self.margins; insets.top = f; self.margins = insets; }
- (void)setMarginBottom:(CGFloat)f  { UIEdgeInsets insets = self.margins; insets.bottom = f; self.margins = insets; }
- (void)setMarginRight:(CGFloat)f   { UIEdgeInsets insets = self.margins; insets.right = f; self.margins = insets; }
- (void)setPaddingLeft:(CGFloat)f   { UIEdgeInsets insets = self.padding; insets.left = f; self.padding = insets; }
- (void)setPaddingTop:(CGFloat)f    { UIEdgeInsets insets = self.padding; insets.top = f; self.padding = insets; }
- (void)setPaddingBottom:(CGFloat)f { UIEdgeInsets insets = self.padding; insets.bottom = f; self.padding = insets; }
- (void)setPaddingRight:(CGFloat)f  { UIEdgeInsets insets = self.padding; insets.right = f; self.padding = insets; }


- (CGFloat)maximumWidth  { return self.maximumSize.width; }
- (CGFloat)maximumHeight { return self.maximumSize.height; }
- (CGFloat)minimumWidth  { return self.minimumSize.width; }
- (CGFloat)minimumHeight { return self.minimumSize.height; }
- (CGFloat)fixedWidth    { return (self.maximumWidth == self.minimumWidth) ? self.maximumWidth : MAXFLOAT; }
- (CGFloat)fixedHeight   { return (self.maximumHeight == self.minimumHeight) ? self.maximumHeight : MAXFLOAT; }
- (CGFloat)marginLeft    { return self.margins.left; }
- (CGFloat)marginTop     { return self.margins.top; }
- (CGFloat)marginBottom  { return self.margins.bottom; }
- (CGFloat)marginRight   { return self.margins.right; }
- (CGFloat)paddingLeft   { return self.padding.left; }
- (CGFloat)paddingTop    { return self.padding.top; }
- (CGFloat)paddingBottom { return self.padding.bottom; }
- (CGFloat)paddingRight  { return self.padding.right; }

- (void)UIView_Layout_layoutSubviews{
    [self UIView_Layout_layoutSubviews];
    
    if(self.layoutBoxes && !self.containerLayoutBox){
        [self performLayoutWithFrame:self.bounds];
    }
}

- (id)UIView_Layout_init{
    self = [self UIView_Layout_init];
    [CKLayoutBox initializeBox:self];
    return self;
}

- (id)UIView_Layout_initWithFrame:(CGRect)frame{
    self = [self UIView_Layout_initWithFrame:frame];
    [CKLayoutBox initializeBox:self];
    return self;
}

- (void)UIView_Layout_setHidden:(BOOL)thehidden{
    if(thehidden != self.hidden){
        [self UIView_Layout_setHidden:thehidden];
        [self invalidateLayout];
    }
}

/*- (BOOL)UIView_Layout_isHidden{
    BOOL selfHidden = [self UIView_Layout_isHidden];
    if(selfHidden)
        return YES;
    
    if(self.containerLayoutBox){
        id container = [self containerLayoutBox];
        while(container){
            if([container isHidden])
                return YES;
            container = [container containerLayoutBox];
        }
    }
    
    return NO;
}*/

- (void)UIView_Layout_setTransform:(CGAffineTransform)theTransform{
  /*  if(!CGAffineTransformEqualToTransform(theTransform, self.transform)){
        [self UIView_Layout_setTransform:theTransform];
        [self invalidateLayout];
    }
   */
}

+ (void)load{
    CKSwizzleSelector([UIView class], @selector(layoutSubviews), @selector(UIView_Layout_layoutSubviews));
    CKSwizzleSelector([UIView class], @selector(init), @selector(UIView_Layout_init));
    CKSwizzleSelector([UIView class], @selector(initWithFrame:), @selector(UIView_Layout_initWithFrame:));
    CKSwizzleSelector([UIView class], @selector(setHidden:), @selector(UIView_Layout_setHidden:));
  //  CKSwizzleSelector([UIView class], @selector(isHidden), @selector(UIView_Layout_isHidden));
  //  CKSwizzleSelector([UIView class], @selector(setTransform:), @selector(UIView_Layout_setTransform:));
}

@end




@implementation UIView(CKLayout_Deprecated)

- (void)setSizeToFitLayoutBoxes:(BOOL)sizeToFitLayoutBoxes{
    self.flexibleSize = !sizeToFitLayoutBoxes;
}

- (BOOL)sizeToFitLayoutBoxes{
    return !self.flexibleSize;
}

@end

