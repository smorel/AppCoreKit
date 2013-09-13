//
//  CKSheetController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKSheetController.h"
#import "CKWeakRef.h"
#import "CKVersion.h"

NSString *const CKSheetResignNotification           = @"CKSheetResignNotification";
NSString *const CKSheetWillShowNotification         = @"CKSheetWillShowNotification";
NSString *const CKSheetWillHideNotification         = @"CKSheetWillHideNotification";
NSString *const CKSheetDidShowNotification          = @"CKSheetDidShowNotification";
NSString *const CKSheetDidHideNotification          = @"CKSheetDidHideNotification";
NSString *const CKSheetFrameEndUserInfoKey          = @"CKSheetFrameEndUserInfoKey";
NSString *const CKSheetAnimationDurationUserInfoKey = @"CKSheetAnimationDurationUserInfoKey";
NSString *const CKSheetAnimationCurveUserInfoKey    = @"CKSheetAnimationCurveUserInfoKey";
NSString *const CKSheetKeyboardWillShowInfoKey      = @"CKSheetKeyboardWillShowInfoKey";

@interface CKSheetController()//PRIVATE
@property(nonatomic,retain) UIView* sheetView;
@property(nonatomic,assign, readwrite) BOOL visible;
@property(nonatomic,assign) BOOL registeredToNotifications;
@property(nonatomic,retain) CKWeakRef* delegateRef;
@property(nonatomic,retain,readwrite) UIViewController* contentViewController;
@end

@implementation CKSheetController{
    id _delegate;
    UIViewController* _contentViewController;
    UIView* _sheetView;
}

@synthesize delegate = _delegate;
@synthesize contentViewController = _contentViewController;
@synthesize sheetView = _sheetView;
@synthesize visible;
@synthesize registeredToNotifications = _registeredToNotifications;
@synthesize delegateRef = _delegateRef;

- (id)initWithContentViewController:(UIViewController *)viewController{
    self = [super init];
    self.contentViewController = viewController;
    self.visible = NO;
    return self;
}

- (void)setDelegate:(id)delegate{
    self.delegateRef = [CKWeakRef weakRefWithObject:delegate];
}

- (id)delegate{
    return [self.delegateRef object];
}

- (void)dealloc{
    if(_registeredToNotifications){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CKSheetResignNotification object:nil];
    }
    
    [_contentViewController release];
    [_sheetView release];
    [_delegateRef release];
    
    [super dealloc];
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated{
   [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldResign:) name:CKSheetResignNotification object:nil];
    self.registeredToNotifications = YES;
    
    //this will retain the CKSheetController until it will get dismissed.
    //this avoid us to explicitelly retain it in the client code.
    [self retain];
    
    
    UIView* contentView = self.contentViewController.view;
    if([CKOSVersion() floatValue] >= 7){
        //contentView.backgroundColor = [UIColor whiteColor];
        UIToolbar* blurView = [[UIToolbar alloc]initWithFrame:contentView.bounds];
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [contentView insertSubview:blurView atIndex:0];
    }
    
    UIView* toolbar = self.contentViewController.navigationItem.titleView;
    
    CGSize size = self.contentViewController.contentSizeForViewInPopover;
                                                            
    CGFloat height = size.height + (toolbar ? toolbar.frame.size.height : 0);
    CGRect contentEndRect = CGRectMake(rect.origin.x,rect.origin.y + rect.size.height - height,
                                       rect.size.width,height);
    
    
    self.sheetView = [[[UIView alloc]initWithFrame:contentEndRect]autorelease];
    CGFloat y = 0;
    if(toolbar){
        toolbar.frame = CGRectMake(0,0,contentEndRect.size.width,toolbar.frame.size.height);
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.sheetView addSubview:toolbar];
        y = toolbar.frame.size.height;
    }
    
    contentView.frame = CGRectMake(0,y,contentEndRect.size.width,contentEndRect.size.height - y);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.sheetView addSubview:contentView];
    //add toolbar 
    //add contentview
    
    UIWindow* window = [view window];
    CGRect contentEndRectInWindow = [window convertRect:contentEndRect fromView:view];
    
    
    if(_delegate && [_delegate respondsToSelector:@selector(sheetControllerWillShowSheet:)]){
        [_delegate sheetControllerWillShowSheet:self];
    }
    
    CGRect contentOriginRect = CGRectMake(rect.origin.x,rect.origin.y + rect.size.height,
                                          rect.size.width,height);
    self.sheetView.frame = contentOriginRect;
    
    [_contentViewController viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetWillShowNotification 
                                                       object:self 
                                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [NSValue valueWithCGRect:contentEndRectInWindow],
                                                               CKSheetFrameEndUserInfoKey,
                                                               [NSNumber numberWithFloat:((animated == YES) ? 0.3 : 0)],
                                                               CKSheetAnimationDurationUserInfoKey, 
                                                               [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut],
                                                               CKSheetAnimationCurveUserInfoKey,
                                                               nil]];
    

    
    [view addSubview:self.sheetView];
    if(animated){
        [[view window]endEditing:YES];//resign keyboard
        [UIView animateWithDuration:0.3
                         animations:^{self.sheetView.frame = contentEndRect;}
                         completion:^(BOOL finished){
                             if(_delegate && [_delegate respondsToSelector:@selector(sheetControllerDidShowSheet:)]){
                                 [_delegate sheetControllerDidShowSheet:self];
                             }
                             [_contentViewController viewDidAppear:animated];
                             
                             [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetDidShowNotification 
                                                                                object:self 
                                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                        [NSValue valueWithCGRect:contentEndRectInWindow],
                                                                                        CKSheetFrameEndUserInfoKey,
                                                                                        [NSNumber numberWithFloat:((animated == YES) ? 0.3 : 0)],
                                                                                        CKSheetAnimationDurationUserInfoKey, 
                                                                                        [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut],
                                                                                        CKSheetAnimationCurveUserInfoKey,
                                                                                        nil]];
                         }];
    }
    else{
        self.sheetView.frame = contentEndRect;    
        [[view window]endEditing:YES];//resign keyboard
        if(_delegate && [_delegate respondsToSelector:@selector(sheetControllerDidShowSheet:)]){
            [_delegate sheetControllerDidShowSheet:self];
        }
        [_contentViewController viewDidAppear:animated];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetDidShowNotification 
                                                           object:self 
                                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [NSValue valueWithCGRect:contentEndRectInWindow],
                                                                   CKSheetFrameEndUserInfoKey,
                                                                   [NSNumber numberWithFloat:((animated == YES) ? 0.3 : 0)],
                                                                   CKSheetAnimationDurationUserInfoKey, 
                                                                   [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut],
                                                                   CKSheetAnimationCurveUserInfoKey,
                                                                   nil]];
    }
    
    self.visible = YES;
}

- (void)dismissSheetAnimated:(BOOL)animated  causedByKeyboard:(BOOL)causedByKeyboard{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CKSheetResignNotification object:nil];
    
    self.registeredToNotifications = NO;
    
    UIView* contentView = self.sheetView;
    
    CGRect contentEndRect = CGRectMake(contentView.frame.origin.x,contentView.frame.origin.y + contentView.frame.size.height,
                                       contentView.frame.size.width,contentView.frame.size.height);
    
    
    UIWindow* window = [contentView window];
    CGRect contentEndRectInWindow = [window convertRect:contentEndRect fromView:[contentView superview]];
    
    if(_delegate && [_delegate respondsToSelector:@selector(sheetControllerWillDismissSheet:)]){
        [_delegate sheetControllerWillDismissSheet:self];
    }
    [_contentViewController viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CKSheetWillHideNotification 
                                                        object:self 
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [NSValue valueWithCGRect:contentEndRectInWindow],
                                                                CKSheetFrameEndUserInfoKey,
                                                                [NSNumber numberWithFloat:((animated == YES) ? 0.3 : 0)],
                                                                CKSheetAnimationDurationUserInfoKey, 
                                                                [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut],
                                                                CKSheetAnimationCurveUserInfoKey,
                                                                [NSNumber numberWithBool:NO],
                                                                CKSheetKeyboardWillShowInfoKey,
                                                                nil]];

    
    if(animated){
        [UIView animateWithDuration:0.3
                         animations:^{contentView.frame = contentEndRect;}
                         completion:^(BOOL finished){ 
                             [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
                             [contentView removeFromSuperview]; 
                             
                             if(_delegate && [_delegate respondsToSelector:@selector(sheetControllerDidDismissSheet:)]){
                                 [_delegate sheetControllerDidDismissSheet:self];
                             }
                             [_contentViewController viewDidDisappear:animated];
                             
                             [[NSNotificationCenter defaultCenter] postNotificationName:CKSheetDidHideNotification 
                                                                                 object:self 
                                                                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                         [NSValue valueWithCGRect:contentEndRectInWindow],
                                                                                         CKSheetFrameEndUserInfoKey,
                                                                                         [NSNumber numberWithFloat:((animated == YES) ? 0.3 : 0)],
                                                                                         CKSheetAnimationDurationUserInfoKey, 
                                                                                         [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut],
                                                                                         CKSheetAnimationCurveUserInfoKey,
                                                                                         [NSNumber numberWithBool:causedByKeyboard],
                                                                                         CKSheetKeyboardWillShowInfoKey,
                                                                                         nil]];

                             self.sheetView = nil;
                             [self autorelease];
                         }];
    }
    else{
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [contentView removeFromSuperview];
        
        if(_delegate && [_delegate respondsToSelector:@selector(sheetControllerDidDismissSheet:)]){
            [_delegate sheetControllerDidDismissSheet:self];
        }
        [_contentViewController viewDidDisappear:animated];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CKSheetDidHideNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [NSValue valueWithCGRect:contentEndRectInWindow],
                                                                    CKSheetFrameEndUserInfoKey,
                                                                    [NSNumber numberWithFloat:((animated == YES) ? 0.3 : 0)],
                                                                    CKSheetAnimationDurationUserInfoKey, 
                                                                    [NSNumber numberWithInt:UIViewAnimationOptionCurveEaseInOut],
                                                                    CKSheetAnimationCurveUserInfoKey,
                                                                    [NSNumber numberWithBool:causedByKeyboard],
                                                                    CKSheetKeyboardWillShowInfoKey,
                                                                    nil]];
        
        self.sheetView = nil;
        [self autorelease];
    }    
    
    self.visible = NO;
}

- (void)dismissSheetAnimated:(BOOL)animated{
    [self dismissSheetAnimated:animated causedByKeyboard:NO];
}

- (void)keyboardDidShow:(NSNotification*)notif{
    [self dismissSheetAnimated:YES causedByKeyboard:YES]; 
}

- (void)shouldResign:(NSNotification*)notif{
    [self dismissSheetAnimated:YES causedByKeyboard:NO]; 
}


@end

