//
//  CKSegmentedViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

#import "CKSegmentedViewController.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import "NSObject+Bindings.h"
#import "UIView+Positioning.h"
#import "UIViewController+Style.h"

@interface CKSegmentedViewController() 
- (void)updateSegmentPositionUsingPosition:(CKSegmentedViewControllerPosition)position;
- (void)updateSegmentUsingViewControllers:(NSArray*)controllers;
@property(nonatomic,retain,readwrite) CKSegmentedControl* segmentedControl;
@property(nonatomic,retain) NSString* internalBindingContext;
@end

@implementation CKSegmentedViewController
@synthesize segmentPosition = _segmentPosition;
@synthesize segmentedControl = _segmentedControl;
@synthesize internalBindingContext = _internalBindingContext;

- (void)segmentPositionExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKSegmentedViewControllerPosition", 
                                               CKSegmentedViewControllerPositionTop,
                                               CKSegmentedViewControllerPositionBottom,
                                               CKSegmentedViewControllerPositionNavigationBar);
}

- (void)postInit{
    [super postInit];
    _segmentPosition = CKSegmentedViewControllerPositionNavigationBar;
    self.internalBindingContext = [NSString stringWithFormat:@"<%p>_internal",self];
}

- (void)dealloc{
    [NSObject removeAllBindingsForContext:_internalBindingContext];
    [_internalBindingContext release];
    [_segmentedControl release];
    [super dealloc];
}

- (void)setSegmentPosition:(CKSegmentedViewControllerPosition)theSegmentPosition{
    if(theSegmentPosition != _segmentPosition){
        [self updateSegmentPositionUsingPosition:theSegmentPosition];
        _segmentPosition = theSegmentPosition;
    }
}

- (void)viewDidUnload{
    [_segmentedControl release];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self updateSegmentUsingViewControllers:self.viewControllers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if([_segmentedControl superview]){
        switch(self.segmentPosition){
            case CKSegmentedViewControllerPositionToolBar:{
                [self.navigationController setToolbarHidden:YES animated:animated];
            }
        }
    }
}

- (void) setViewControllers:(NSArray *)viewControllers{
    [super setViewControllers:viewControllers];
    [self updateSegmentUsingViewControllers:viewControllers];
}

- (void)updateSegmentPositionUsingPosition:(CKSegmentedViewControllerPosition)position{
    //place the controller's view as if no segmented control
    if([_segmentedControl superview]){
        switch(self.segmentPosition){
            case CKSegmentedViewControllerPositionTop:
            case CKSegmentedViewControllerPositionBottom:{
                self.containerView.frame = self.view.bounds;
                [self.segmentedControl removeFromSuperview];
                break;
            }
            case CKSegmentedViewControllerPositionNavigationBar:{
                self.navigationItem.titleView = nil;
                break;
            }
            case CKSegmentedViewControllerPositionToolBar:{
                [self.navigationController setToolbarHidden:YES animated:YES];
            }
        }
    }
    
    //place the segmented control
    switch(self.segmentPosition){
        case CKSegmentedViewControllerPositionTop:{
            self.containerView.y = self.segmentedControl.height;
            self.containerView.height = [self.view height] - self.segmentedControl.height;
            self.segmentedControl.y = 0;
            self.segmentedControl.x = 0;
            self.segmentedControl.width = self.view.width;
            self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            [self.view addSubview:self.segmentedControl];
            break;
        }
        case CKSegmentedViewControllerPositionBottom:{
            self.containerView.height = [self.view height] - self.segmentedControl.height;
            self.segmentedControl.y = self.containerView.height;
            self.segmentedControl.x = 0;
            self.segmentedControl.width = self.view.width;
            self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            [self.view addSubview:self.segmentedControl];
            break;
        }
        case CKSegmentedViewControllerPositionNavigationBar:{
            self.navigationItem.titleView = self.segmentedControl;
            break;
        }
        case CKSegmentedViewControllerPositionToolBar:{
            [self setToolbarItems:[NSArray arrayWithObjects:
                                   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                                   [[[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl] autorelease],
                                   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                                   nil] animated:NO];
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    }
}


- (void)updateSegmentUsingViewControllers:(NSArray*)controllers{
    if(self.state == CKViewControllerStateWillAppear ||
       self.state == CKViewControllerStateDidAppear){
        
        if(_segmentedControl){
            [_segmentedControl removeFromSuperview];
        }
        
        __block CKSegmentedViewController* bself = self;
        [NSObject beginBindingsContext:self.internalBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
        NSMutableArray* items = [NSMutableArray array];
        int i =0;
        for(UIViewController* controller in controllers){
            NSString* title = [controller title];
            [items addObject:title ? title : _(@"No Title")];
            __block UIViewController* bController = controller;
            [controller bind:@"title" withBlock:^(id value) {
                CKSegmentedControlButton* segment = [bself.segmentedControl segmentAtIndex:i];
                [segment setTitle:[bController title] forState:UIControlStateNormal];
            }];
            ++i;
        }
        [NSObject endBindingsContext];

        
        self.segmentedControl = [[[CKSegmentedControl alloc]initWithItems:items]autorelease];
        [self.segmentedControl addTarget:self action:@selector(changeList:) forControlEvents:UIControlEventValueChanged];
        [self updateSegmentPositionUsingPosition:self.segmentPosition];
        self.segmentedControl.selectedSegmentIndex = 0;
        
        [self applyStyle];
    }
}

- (void)changeList:(id)sender {
    BOOL animated = (self.state == CKViewControllerStateDidAppear);
    [self presentViewControllerAtIndex:self.segmentedControl.selectedSegmentIndex withTransition:animated ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationTransitionNone];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
