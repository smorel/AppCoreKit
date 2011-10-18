//
//  CKInlineDebuggerController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-10-18.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKInlineDebuggerController.h"
#import "CKWeakRef.h"
#import "CKUIViewController+InlineDebugger.h"
#import "CKLocalization.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Positioning.h"


typedef enum CKDebugCheckState{
    CKDebugCheckState_none,
    CKDebugCheckState_NO,
    CKDebugCheckState_YES
}CKDebugCheckState;

static CKDebugCheckState CKDebugInlineDebuggerEnabledState = CKDebugCheckState_none;

@interface CKInlineDebuggerController()
@property(nonatomic,retain)CKWeakRef* viewControllerRef;
@property(nonatomic,readonly)UIViewController* viewController;
@property(nonatomic,assign,readwrite)CKInlineDebuggerControllerState state;
@property (nonatomic,retain) id debugModalController;
@property(nonatomic,retain)UIView* touchedView;
@property(nonatomic,retain)UIView* debuggingView;
@property(nonatomic,retain)UIView* debuggingHighlightView;
@property(nonatomic,retain)NSMutableArray* supperHighlightViews;
@property(nonatomic,retain)UILabel* highlightLabel;
@property(nonatomic,retain)NSMutableArray* possibleSuperViews;
@property(nonatomic,retain)NSMutableArray* customGestures;
@property(nonatomic,retain)UITapGestureRecognizer* mainGesture;
@property(nonatomic,retain)UIBarButtonItem* oldRightButtonItem;

- (void)highlightView:(UIView*)view;

@end

@implementation CKInlineDebuggerController
@synthesize viewControllerRef = _viewControllerRef;
@synthesize debugModalController = _debugModalController;
@synthesize debuggingView = _debuggingView;
@synthesize debuggingHighlightView = _debuggingHighlightView;
@synthesize supperHighlightViews = _supperHighlightViews;
@synthesize highlightLabel = _highlightLabel;
@synthesize possibleSuperViews = _possibleSuperViews;
@synthesize touchedView = _touchedView;
@synthesize customGestures = _customGestures;
@synthesize mainGesture = _mainGesture;
@synthesize oldRightButtonItem = _oldRightButtonItem;
@synthesize state;
@synthesize viewController;

- (id)initWithViewController:(UIViewController*)theviewController{
    self = [super init];
    self.state = CKInlineDebuggerControllerStatePending;
    self.viewControllerRef = [CKWeakRef weakRefWithObject:theviewController];
    
    return self;
}

- (void)start{
#ifdef DEBUG
    if(CKDebugInlineDebuggerEnabledState == CKDebugCheckState_none){
        BOOL bo = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CKInlineDebuggerEnabled"]boolValue];
        CKDebugInlineDebuggerEnabledState = bo ? CKDebugCheckState_YES : CKDebugCheckState_NO;
    }
    
    if(CKDebugInlineDebuggerEnabledState == CKDebugCheckState_YES){
        self.customGestures = [NSMutableArray array];
        
        self.mainGesture = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(twoTapGesture:)]autorelease];
        _mainGesture.numberOfTapsRequired = 2;
        [self.viewController.navigationController.navigationBar addGestureRecognizer:_mainGesture];
    }
#endif
}

- (void)stop{
#ifdef DEBUG
    [self.viewController.navigationController.navigationBar removeGestureRecognizer:self.mainGesture];
#endif
}

- (void)dealloc{
    if(self.viewController){
        [self highlightView:nil];
        [self.viewController.navigationController.navigationBar removeGestureRecognizer:self.mainGesture];
        self.viewController.navigationItem.rightBarButtonItem = self.oldRightButtonItem;
    }
    [_viewControllerRef release];
    _viewControllerRef = nil;
    [_debugModalController release];
    _debugModalController = nil;
    [_debuggingHighlightView release];
    _debuggingHighlightView = nil;
    [_debuggingView release];
    _debuggingView = nil;
    [_supperHighlightViews release];
    _supperHighlightViews = nil;
    [_highlightLabel release];
    _highlightLabel = nil;
    [_possibleSuperViews release];
    _possibleSuperViews = nil;
    [_touchedView release];
    _touchedView = nil;
    [_customGestures release];
    _customGestures = nil;
    [_mainGesture release];
    _mainGesture = nil;
    [_oldRightButtonItem release];
    _oldRightButtonItem = nil;
    [super dealloc];
}

- (UIViewController*)viewController{
    return self.viewControllerRef.object;
}

/********************************* HIT TEST *******************************
 */

- (void)hitTest:(CGPoint)point currentOrigin:(CGPoint)origin inView:(UIView*)view stack:(NSMutableArray*)stack{
    if(view == self.debuggingHighlightView
       || view == self.highlightLabel
       || ( _supperHighlightViews && [self.supperHighlightViews indexOfObjectIdenticalTo:view] != NSNotFound)){
    }
    else{
        origin = CGPointMake(origin.x + view.frame.origin.x,origin.y + view.frame.origin.y);
        CGPoint offset = CGPointMake(point.x - origin.x,point.y - origin.y);
        if(offset.x >= 0 && offset.y >= 0
           && offset.x <= view.frame.size.width
           && offset.y <= view.frame.size.height){
            [stack insertObject:view atIndex:0];
        }
    }
    
    for(UIView* v in view.subviews){
        [self hitTest:point currentOrigin:origin inView:v stack:stack];
    }
}

- (void)hitTest:(CGPoint)point stack:(NSMutableArray*)stack{
    [self hitTest:point currentOrigin:CGPointMake(0,0) inView:self.viewController.view stack:stack];
}

- (UIView*)hitTest:(CGPoint)point{
    NSMutableArray* stack = [NSMutableArray array];
    [self hitTest:point stack:stack];
    return [stack count] > 0 ? [stack objectAtIndex:0] : nil;
}

- (BOOL)isView:(UIView*)superView supperViewOf:(UIView*)view{
    UIView* v = view;
    while(v){
        if(v == superView){
            return YES;
        }
        v = [v superview];
    }
    return NO;
}

/******************************** Debugger View Controller **************************
 */

- (void)presentInlineDebuggerForSubView:(UIView*)view fromParentController:(UIViewController*)controller{
    CKFormTableViewController* debugger = [self.viewController inlineDebuggerForSubView:view];
    
    debugger.title = [NSString stringWithFormat:@"%@ <%p>",[view class],view];
    UIBarButtonItem* close = [[[UIBarButtonItem alloc] initWithTitle:_(@"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(closeDebug:)]autorelease];
    debugger.leftButton = close;
    UINavigationController* navc = [[[UINavigationController alloc]initWithRootViewController:debugger]autorelease];
    navc.modalPresentationStyle = UIModalPresentationPageSheet;
    
    self.debugModalController = debugger;
    
    [controller presentModalViewController:navc animated:YES];
}

- (void)closeDebug:(id)sender{
	[self.debugModalController dismissModalViewControllerAnimated:YES];
	self.debugModalController = nil;
}

/******************************** GESTURES *******************************
 */

- (void)computeTopViews:(NSMutableArray*)topViews inView:(UIView*)view{
    if([[view subviews]count] == 0){
        [topViews addObject:view];
    }
    else{
        for(UIView* v in [view subviews]){
            [self computeTopViews:topViews inView:v];
        }
    }
}

- (void)computePossibleSuperViewfromView:(UIView*)view{
    NSMutableArray* topViews = [NSMutableArray array];
    [topViews addObject:view];
    [self computeTopViews:topViews inView:[view superview]];
    self.possibleSuperViews = topViews;
}

- (void)highlightView:(UIView*)view{
    if(self.debuggingView != view){
        for(UIView* v in _supperHighlightViews){
            [v removeFromSuperview];
        }
        
        if(view == nil){
            self.debuggingView = nil;
            [_debuggingHighlightView removeFromSuperview];
            [_highlightLabel removeFromSuperview];
        }
        else{
            if(_debuggingHighlightView == nil){
                self.debuggingHighlightView = [[[UIView alloc]initWithFrame:view.bounds]autorelease];
                _debuggingHighlightView.backgroundColor = [UIColor redColor];
                _debuggingHighlightView.alpha = 0.4;
            }
            
            self.debuggingView = view;
            _debuggingHighlightView.frame = view.bounds;
            [view addSubview:_debuggingHighlightView];
            
            [self computePossibleSuperViewfromView:view];
            
            if(_supperHighlightViews == nil){
                self.supperHighlightViews = [NSMutableArray array];
            }
            
            int i =0;
            for(UIView* v in self.possibleSuperViews){
                if(v != _highlightLabel){
                    if(i >= [_supperHighlightViews count]){
                        UIView* subViewHighlight = [[[UIView alloc]initWithFrame:v.bounds]autorelease];
                        subViewHighlight.backgroundColor = [UIColor clearColor];
                        subViewHighlight.layer.borderWidth = 1;
                        subViewHighlight.layer.borderColor = [[UIColor colorWithRed:((float)rand()/(float)RAND_MAX) 
                                                                             green:((float)rand()/(float)RAND_MAX) 
                                                                              blue:((float)rand()/(float)RAND_MAX)  
                                                                             alpha:1]CGColor];
                        [_supperHighlightViews addObject:subViewHighlight];
                    }
                    
                    UIView* hv = [_supperHighlightViews objectAtIndex:i];
                    hv.frame = v.bounds;
                    [v addSubview:hv];
                    ++i;
                }
            }
            
            if(_highlightLabel == nil){
                self.highlightLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 20)]autorelease];
                _highlightLabel.layer.cornerRadius = 10;
                _highlightLabel.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6];
                _highlightLabel.textColor = [UIColor whiteColor];
                _highlightLabel.textAlignment = UITextAlignmentCenter;
            }
            
            _highlightLabel.text = [[view class]description];
            [_highlightLabel sizeToFit];
            
            _highlightLabel.width += 20;
            _highlightLabel.center = self.viewController.view.center;
            _highlightLabel.y = 5;
            
            [self.viewController.view addSubview:_highlightLabel];
        }
    }
}

- (void)tapGesture:(UILongPressGestureRecognizer *)recognizer{
    if(self.state == CKInlineDebuggerControllerStatePending
       || self.debuggingView == nil){
        return;
    }
    
    if(recognizer.state == UIGestureRecognizerStateRecognized){
        CGPoint point = [recognizer locationInView:self.viewController.view];
        UIView* thetouchedView = [self hitTest:point];	
        if(thetouchedView == _debuggingHighlightView){
            thetouchedView = [_debuggingHighlightView superview];
        }
        
        if(thetouchedView != self.touchedView){
            [self highlightView:thetouchedView];
        }
        else{
            NSMutableArray* stack = [NSMutableArray array];
            [self hitTest:point stack:stack];
            
            UIView* touchedSuperView = self.debuggingView;
            for(UIView* v in self.possibleSuperViews){
                NSInteger index = [stack indexOfObjectIdenticalTo:v];
                if(index != NSNotFound){
                    touchedSuperView = v;
                    break;
                }
            }
            
            NSInteger index = [stack indexOfObjectIdenticalTo:touchedSuperView];
            if(index != NSNotFound){
                if(touchedSuperView == self.debuggingView && index < [stack count] - 2){
                    [self highlightView:[stack objectAtIndex:index + 1]];
                }
                else if(touchedSuperView == self.debuggingView && index != NSNotFound){
                    [self highlightView:[stack objectAtIndex:0]];
                }
                else if(touchedSuperView != self.debuggingView){
                    [self highlightView:touchedSuperView];
                }
            }
            else{
                [self highlightView:thetouchedView];
            }
        }
        
        self.touchedView = thetouchedView;
    }
}

- (void)twoTapGesture:(UILongPressGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateRecognized){
        CGPoint point = [recognizer locationInView:self.viewController.view];
        UIView* touchedView = [self hitTest:point];	
        if(touchedView == _debuggingHighlightView){
            touchedView = [_debuggingHighlightView superview];
        }
        
        self.state = (self.state == CKInlineDebuggerControllerStatePending) ? CKInlineDebuggerControllerStateDebugging : CKInlineDebuggerControllerStatePending;
        if(self.state == CKInlineDebuggerControllerStatePending){
            for(UIGestureRecognizer* gesture in self.customGestures){
                [self.viewController.view removeGestureRecognizer:gesture];
            }
            for(UIView* v in [self.viewController.view subviews]){
                v.userInteractionEnabled = YES;
            }
            [self highlightView:nil];
            self.viewController.navigationItem.rightBarButtonItem = self.oldRightButtonItem;
        }
        else{
            self.oldRightButtonItem = self.viewController.navigationItem.rightBarButtonItem;
            self.viewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithTitle:_(@"Inspector") style:UIBarButtonItemStyleBordered target:self action:@selector(inspector:)]autorelease];
            
            UITapGestureRecognizer* tapGesture = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)]autorelease];
            tapGesture.numberOfTapsRequired = 1;
            [self.viewController.view addGestureRecognizer:tapGesture];
            [self.customGestures addObject:tapGesture];
            
            UILongPressGestureRecognizer* longGesture = [[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)]autorelease];
            longGesture.allowableMovement = 10000;
            [self.viewController.view addGestureRecognizer:longGesture];
            [self.customGestures addObject:longGesture];
            
            for(UIView* v in [self.viewController.view subviews]){
                v.userInteractionEnabled = NO;
            }
            [self highlightView:touchedView ? touchedView : self.viewController.view];
        }
    }
}

- (void)longGesture:(UILongPressGestureRecognizer *)recognizer{
    if(self.state == CKInlineDebuggerControllerStatePending){
        return;
    }
    
    CGPoint point = [recognizer locationInView:self.viewController.view];
    UIView* touchedView = [self hitTest:point];	
    if(touchedView == _debuggingHighlightView){
        touchedView = [_debuggingHighlightView superview];
    }
    
    [self highlightView:touchedView];
}

- (void)inspector:(id)sender{
    UINavigationController* myNavigationController = self.viewController.navigationController;
    UIViewController* topController = [myNavigationController topViewController];
    [self presentInlineDebuggerForSubView:self.debuggingView fromParentController:topController];
}

@end
