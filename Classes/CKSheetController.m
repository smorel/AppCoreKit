//
//  CKSheetController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-01.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKSheetController.h"

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
@end

@implementation CKSheetController
@synthesize delegate = _delegate;
@synthesize contentViewController = _contentViewController;

- (id)initWithContentViewController:(UIViewController *)viewController{
    self = [super init];
    self.contentViewController = viewController;
    return self;
}

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated{
   [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldResign:) name:CKSheetResignNotification object:nil];
    
    //this will retain the CKSheetController until it will get dismissed.
    //this avoid us to explicitelly retain it in the client code.
    [self retain];
    
    UIView* contentView = self.contentViewController.view;
    //contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.backgroundColor = [UIColor redColor];
    
    CGSize size = self.contentViewController.contentSizeForViewInPopover;
    CGFloat height = size.height;
    CGRect contentEndRect = CGRectMake(rect.origin.x,rect.origin.y + rect.size.height - height,
                                       rect.size.width,height);
    
    UIWindow* window = [view window];
    CGRect contentEndRectInWindow = [window convertRect:contentEndRect fromView:view];
    
    
    if(_delegate && [_delegate respondsToSelector:@selector(sheetControllerWillShowSheet:)]){
        [_delegate sheetControllerWillShowSheet:self];
    }
    
    CGRect contentOriginRect = CGRectMake(rect.origin.x,rect.origin.y + rect.size.height,
                                          rect.size.width,height);
    contentView.frame = contentOriginRect;
    
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
    

    
    [view addSubview:contentView];
    if(animated){
        [UIView animateWithDuration:0.3
                         animations:^{contentView.frame = contentEndRect;}
                         completion:^(BOOL finished){
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
                         }];
    }
    else{
        contentView.frame = contentEndRect;    
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
}

- (void)dismissSheetAnimated:(BOOL)animated  causedByKeyboard:(BOOL)causedByKeyboard{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CKSheetResignNotification object:nil];
    
    UIView* contentView = self.contentViewController.view;
    
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
                                                                [NSNumber numberWithBool:causedByKeyboard],
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

        
        [self autorelease];
    }    
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

