//
//  CKMapAnnotationController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKMapAnnotationController.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKUIView+Positioning.h"

#import "CKNSObject+Invocation.h"
#import <objc/runtime.h>
#import "CKRuntime.h"
#import <QuartzCore/QuartzCore.h>
#import "CKBindedMapViewController.h"

@interface CKCalloutView : UIView
@property (nonatomic,retain) UIView* calloutView;
@end

@implementation CKCalloutView
@synthesize calloutView = _calloutView;

+ (void)load{
    Class c = NSClassFromString(@"UICalloutView");
    class_setSuperclass([CKCalloutView class], c);
}

- (void)dealloc{
    [_calloutView release];
    _calloutView = nil;
    [super dealloc];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if(_calloutView){
        self.clipsToBounds = NO;
        
        
        UIImageView* arrowTop = (UIImageView*)[[self subviews]objectAtIndex:2];
        arrowTop.hidden = YES;
        
        UIImageView* arrowBottom = (UIImageView*)[[self subviews]objectAtIndex:3];
        
        _calloutView.y = - _calloutView.height + self.height - [self superview].height;
        _calloutView.x = arrowBottom.x + (arrowBottom.width / 2) - (_calloutView.width / 2);
        _calloutView.autoresizingMask = UIViewAutoresizingNone;
        _calloutView.layer.cornerRadius = 5;
        _calloutView.clipsToBounds = YES;
        
        arrowBottom.image = [arrowBottom.image stretchableImageWithLeftCapWidth:2 topCapHeight:19];
        arrowBottom.x = _calloutView.x + (_calloutView.width / 2) - 20;
        arrowBottom.y = _calloutView.y - 6;
        arrowBottom.width = 41;
        arrowBottom.height = _calloutView.height + 6 + 29;
        
        
        UIImageView* leftBorderView = (UIImageView*)[[self subviews]objectAtIndex:0];
        leftBorderView.image = [leftBorderView.image stretchableImageWithLeftCapWidth:16 topCapHeight:20];
        leftBorderView.x = _calloutView.x - 10;
        leftBorderView.y = _calloutView.y - 6;
        leftBorderView.width = arrowBottom.x - leftBorderView.x;
        
        UIImageView* rightBorderView = (UIImageView*)[[self subviews]objectAtIndex:1];
        rightBorderView.image = [rightBorderView.image stretchableImageWithLeftCapWidth:1 topCapHeight:20];
        rightBorderView.x = arrowBottom.x + arrowBottom.width;
        rightBorderView.y = _calloutView.y - 6;
        rightBorderView.width = leftBorderView.width;
        
        rightBorderView.height = leftBorderView.height = arrowBottom.height - 13;
    }
}

- (CGFloat)UICalloutViewMinimumWidth{
    return _calloutView ? (_calloutView.height + 6) : 43;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint a = [self convertPoint:point toView:_calloutView];
    UIView* v = [_calloutView hitTest:a withEvent:event];
    if(v){
        return v;
    }
    return [super hitTest:point withEvent:event];
}

@end


@implementation CKAnnotationView
@synthesize calloutViewController = _calloutViewController;
@synthesize annotationController = _annotationController;

- (void)dealloc{
    [_calloutViewController release];
    _calloutViewController = nil;
    [super dealloc];
}

- (CKBindedMapViewController*)mapController{
    return (CKBindedMapViewController*)[_annotationController containerController];
}

- (MKMapView*)mapView{
    return [[self mapController] mapView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(_calloutViewController){
        if(selected){
            int i =3;
        }
        else{
            [super setSelected:selected animated:animated];
            [_calloutViewController viewWillDisappear:YES];
            [_calloutViewController.view removeFromSuperview];
            [_calloutViewController viewDidDisappear:YES];
        }
    }
}

- (void)didAddSubview:(UIView *)subview{
    if(_calloutViewController){
        if ([[[subview class] description] isEqualToString:@"UICalloutView"]) {
            object_setClass(subview,[CKCalloutView class]);
            
            CKCalloutView* v = (CKCalloutView*)subview;
            
            UIView* view = [_calloutViewController view];
            CGSize size = _calloutViewController.contentSizeForViewInPopover;
            if([_calloutViewController isKindOfClass:[UINavigationController class]]){
                UINavigationController* nav = (UINavigationController*)_calloutViewController;
                size = nav.topViewController.contentSizeForViewInPopover;
            }
            view.width = size.width;
            view.height = size.height;
            
            v.calloutView = view;
            
            [_calloutViewController viewWillAppear:YES];
            [subview addSubview:view];
            [_calloutViewController viewDidAppear:YES];
        }
    }
}

@end


@implementation CKMapAnnotationController

@synthesize style = _style;
@synthesize deselectionCallback = _deselectionCallback;

- (id)init{
	[super init];
	_style = CKMapAnnotationPin;
	return self;
}

- (void)dealloc{
    [_deselectionCallback release];
    _deselectionCallback = nil;
    [super dealloc];
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
	attributes.enumDescriptor = CKEnumDefinition(@"CKMapAnnotationStyle",
                                               CKMapAnnotationCustom,
											   CKMapAnnotationPin);
}


- (MKAnnotationView*)loadAnnotationView{
	return [self viewWithStyle:_style];
}

- (MKAnnotationView*)viewWithStyle:(CKMapAnnotationStyle)style{
	MKAnnotationView* theView = nil;
	switch(style){
		case CKMapAnnotationPin:{
			theView = [[[MKPinAnnotationView alloc] initWithAnnotation:self.value reuseIdentifier:[self identifier]] autorelease];
			break;
		}
		case CKMapAnnotationCustom:{
			theView = [[[CKAnnotationView alloc]initWithAnnotation:self.value reuseIdentifier:[self identifier]] autorelease];
			break;
		}
	}
	theView.canShowCallout = YES;
	self.view = theView;
	return theView;
}

#pragma mark CKItemViewController Implementation

- (UIView *)loadView{
	MKAnnotationView* view = [self loadAnnotationView];
	[self initView:view];
	[self applyStyle];
	return view;
}

- (void)initView:(UIView*)view{
	[super initView:view];
}

- (void)setupView:(UIView *)view{
    if([view isKindOfClass:[CKAnnotationView class]]){
        [(CKAnnotationView*)view setAnnotationController:self];
    }
	[super setupView:view];
}

- (void)rotateView:(UIView*)view animated:(BOOL)animated{
	[super rotateView:view  animated:animated];
}

- (void)viewDidAppear:(UIView *)view{
	[super viewDidAppear:view];
}

- (void)viewDidDisappear{
	[super viewDidDisappear];
}

- (NSIndexPath *)willSelect{
	return self.indexPath;
}

- (void)didSelect{
	[super didSelect];
}

- (void)didDeselect{
	if(_deselectionCallback != nil){
		[_deselectionCallback execute:self];
	}
}

@end
