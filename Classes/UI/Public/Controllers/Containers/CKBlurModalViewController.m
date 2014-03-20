//
//  CKBlurModalViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2/26/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKBlurModalViewController.h"
#import "UIImage+ImageEffects.h"
#import "CKAnimationManager.h"
#import "CKAnimationInterpolator.h"
#import "CKContainerViewController.h"
#import "UIView+Snapshot.h"
#import "NSObject+Bindings.h"
#import "UIView+Bounce.h"


@interface CKBlurModalViewController ()
@property(nonatomic,retain) UIViewController* contentViewController;
@property(nonatomic,retain) UIImage* renderScreenImage;
@property(nonatomic,retain) UIImageView* blurView;
@property(nonatomic,retain) UIWindow* presentedInWindow;
@property(nonatomic,retain) CKBlurModalViewController* selfRetain;
@property(nonatomic,retain) CKAnimationManager* animationManager;
@property(nonatomic,assign) BOOL isPresented;
@end

@implementation CKBlurModalViewController

- (void)dealloc{
    [_contentViewController release];
    [_renderScreenImage release];
    [_blurView release];
    [_presentedInWindow release];
    [_selfRetain release];
    [_blurTintColor release];
    [_animationManager release];
    
    [super dealloc];
}

#pragma mark ViewController Life Cycle

- (id)initWithContentViewController:(UIViewController*)theContentViewController{
    self = [super init];
    self.contentViewController = theContentViewController;
    [self.contentViewController setContainerViewController:self];
    self.animationDuration = .3;
    self.blurRadius = 2;
    self.saturationDelta = 1;
    self.blurTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.backgroundScale = 0.9;
    self.statusBarAnimation = UIStatusBarAnimationFade;
    return self;
}

- (void)setBlurRadius:(CGFloat)blurRadius{
    _blurRadius = blurRadius;
    
    if(self.isPresented){
        [self renderBlurWithRatio:1];
    }
}

- (void)setBlurTintColor:(UIColor *)blurTintColor{
    [_blurTintColor release];
    
    _blurTintColor = [blurTintColor retain];;
    
    if(self.isPresented){
        [self renderBlurWithRatio:1];
    }
}

- (void)setSaturationDelta:(CGFloat)saturationDelta{
    _saturationDelta = saturationDelta;
    
    if(self.isPresented){
        [self renderBlurWithRatio:1];
    }
}

- (void)setBackgroundScale:(CGFloat)backgroundScale{
    _backgroundScale = backgroundScale;
    
    if(self.isPresented){
        self.blurView.transform = CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale);
    }
}


- (void)renderBlurWithRatio:(CGFloat)ratio{
    const CGFloat* colors     = CGColorGetComponents([self.blurTintColor CGColor]);
    const CGFloat targetAlpha = CGColorGetAlpha([self.blurTintColor CGColor]);
    
    UIImage* image = [self.renderScreenImage applyBlurWithRadius:ratio * self.blurRadius tintColor:[UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:ratio * targetAlpha] saturationDeltaFactor:self.saturationDelta maskImage:nil];
    
    self.blurView.image = image;
}

- (void)presentFromViewController:(UIViewController*)viewController animated:(BOOL)animated completion:(void(^)())completion{
    self.isPresented = NO;
     
    self.presentedInWindow = viewController.view.window;
    self.selfRetain = self;
    
        
    //self.renderScreenImage = [self.presentedInWindow snapshot];
    self.renderScreenImage = [[UIScreen mainScreen]snapshot];
     
    self.blurView = [[[UIImageView alloc]initWithFrame:self.presentedInWindow.bounds]autorelease];
    
    [self.view addSubview:self.blurView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIView* contentView = self.contentViewController.view;
    contentView.frame = CGRectMake(0,self.presentedInWindow.bounds.size.height,self.presentedInWindow.bounds.size.width,self.presentedInWindow.bounds.size.height);
    
    [self.contentViewController viewWillAppear:animated];
    [self.view addSubview:self.contentViewController.view];
    
    self.view.frame = self.presentedInWindow.bounds;
    
    [self.presentedInWindow addSubview:self.view];
    
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:self.statusBarAnimation];
    
    [contentView animateWithBounceFromFrame:CGRectMake(0,self.presentedInWindow.bounds.size.height,self.presentedInWindow.bounds.size.width,self.presentedInWindow.bounds.size.height)
                                    toFrame:CGRectMake(0,0,self.presentedInWindow.bounds.size.width,self.presentedInWindow.bounds.size.height)
                                   duration:(self.animationDuration * 3)
                             numberOfBounce:4
                              numberOfSteps:200
                                    damping:3
                                     update:nil
                                 completion:^(BOOL finished){
            [self.contentViewController viewDidAppear:animated];
            self.isPresented = YES;
            if(completion){
                completion();
            }
    }];
    
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.blurView.transform = CGAffineTransformMakeScale(self.backgroundScale, self.backgroundScale);
    } completion:^(BOOL finished) {
    }];
    
    self.animationManager = [[[CKAnimationManager alloc]init]autorelease];
    [self.animationManager registerInScreen:[UIScreen mainScreen]];
    
    __unsafe_unretained CKBlurModalViewController* bself = self;
    
    CKAnimationInterpolator* interpolator = [[[CKAnimationInterpolator alloc]init]autorelease];
    interpolator.duration = self.animationDuration;
    interpolator.values = @[ @(0.0), @(1.0)];
    interpolator.updateBlock = ^(CKAnimation* animation,id value){
        [bself renderBlurWithRatio:[value floatValue]];
    };
    [interpolator startInManager:self.animationManager];
    
  
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void(^)())completion{
    [self.contentViewController viewWillDisappear:animated];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:self.statusBarAnimation];
    
    UIView* contentView = self.contentViewController.view;
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.blurView.transform = CGAffineTransformMakeScale(1, 1);
        contentView.frame = CGRectMake(0,self.presentedInWindow.bounds.size.height,self.presentedInWindow.bounds.size.width,self.presentedInWindow.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.contentViewController viewDidDisappear:animated];
        [self.view removeFromSuperview];
        self.selfRetain = nil;
        
        [self setContainerViewController:nil];
        [self.contentViewController setContainerViewController:nil];
        self.isPresented = NO;
        
        if(completion){
            completion();
        }
    }];
    
    
    CKAnimationInterpolator* interpolator = [[[CKAnimationInterpolator alloc]init]autorelease];
    interpolator.duration = self.animationDuration;
    interpolator.values = @[ @(1.0), @(0.0)];
    interpolator.updateBlock = ^(CKAnimation* animation,id value){
        [self renderBlurWithRatio:[value floatValue]];
    };
    interpolator.eventBlock = ^(CKAnimation* animation,CKAnimationEvents event){
        if(event == CKAnimationEventEnd){
            [self.animationManager unregisterFromScreen];
            self.animationManager = nil;
            
            [self clearBindingsContext];
        }
    };
    [interpolator startInManager:self.animationManager];
}

@end
