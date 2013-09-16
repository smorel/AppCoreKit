//
//  CKMapAnnotationController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKMapAnnotationController.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+Positioning.h"

#import "NSObject+Invocation.h"
#import <objc/runtime.h>
#import "CKRuntime.h"
#import <QuartzCore/QuartzCore.h>
#import "CKMapCollectionViewController.h"
#import "NSObject+Bindings.h"
#import "CKVersion.h"

static char CKCalloutViewCalloutViewKey;
static char CKCalloutViewCalloutSizeKey;
static char CKCalloutViewCalloutCoordinateKey;
static char CKCalloutViewCalloutMapViewKey;

@interface CKCalloutView : UIView
@end

@implementation CKCalloutView

+ (void)load{
    if([CKOSVersion() floatValue] < 7){
        Class c = NSClassFromString(@"UICalloutView");
        class_setSuperclass([CKCalloutView class], c);
    }else{
        Class c = NSClassFromString(@"MKSmallCalloutView");
        class_setSuperclass([CKCalloutView class], c);
    }
}

- (void)setCalloutView:(UIView *)calloutView{
    objc_setAssociatedObject(self, &CKCalloutViewCalloutViewKey, calloutView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView*)calloutView{
    return objc_getAssociatedObject(self, &CKCalloutViewCalloutViewKey);
}

- (void)setCalloutSize:(CGSize)size{
    objc_setAssociatedObject(self, &CKCalloutViewCalloutSizeKey, [NSValue valueWithCGSize:size], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (CGSize)calloutSize{
    id obj = objc_getAssociatedObject(self, &CKCalloutViewCalloutSizeKey);
    return obj ? [obj CGSizeValue] : CGSizeZero;
}

- (void)setCoordinate:(CLLocationCoordinate2D)c{
    objc_setAssociatedObject(self, &CKCalloutViewCalloutCoordinateKey, [NSValue valueWithMKCoordinate:c], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CLLocationCoordinate2D)coordinate{
    id obj = objc_getAssociatedObject(self, &CKCalloutViewCalloutCoordinateKey);
    return obj ? [obj MKCoordinateValue] : CLLocationCoordinate2DMake(0, 0);
}

//do not retain mapview here
- (void)setMapView:(MKMapView*)view{
    objc_setAssociatedObject(self, &CKCalloutViewCalloutMapViewKey, view, OBJC_ASSOCIATION_ASSIGN);
}

- (MKMapView*)mapView{
    return objc_getAssociatedObject(self, &CKCalloutViewCalloutMapViewKey);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIView* _calloutView = [self calloutView];
    
    if([CKOSVersion() floatValue] < 7){
        
        if(_calloutView){
            self.clipsToBounds = NO;
            
            for(int i =4; i< 8; ++i){
                UIView* view = [[self subviews]objectAtIndex:i];
                view.hidden = YES;
            }
            
            UIImageView* arrowTop = (UIImageView*)[[self subviews]objectAtIndex:2];
            arrowTop.hidden = YES;
            
            UIImageView* arrowBottom = (UIImageView*)[[self subviews]objectAtIndex:3];
            
            _calloutView.y = floorf(- _calloutView.height + self.height - 36);
            _calloutView.x = floorf(arrowBottom.x + (arrowBottom.width / 2) - (_calloutView.width / 2));
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
    }else if(_calloutView){
        _calloutView.x = 1;
        _calloutView.y = 1;
        //_calloutView.frame = CGRectMake(1,1,self.width-1,self.height - 13 - 1);
        _calloutView.layer.cornerRadius = 7;
        _calloutView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        
        for(UIView* subview in self.subviews){
            if([subview isKindOfClass:[UILabel class]]){
                subview.hidden = YES;
            }
        }
    }
}

//ios6 and before ---------------------

- (CGFloat)UICalloutViewMinimumWidth{
    UIView* _calloutView = [self calloutView];
    
    return _calloutView ? ([self calloutSize].height + 6) : 43;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* _calloutView = [self calloutView];
    
    CGPoint a = [self convertPoint:point toView:_calloutView];
    UIView* v = [_calloutView hitTest:a withEvent:event];
    if(v){
        return v;
    }
    return [super hitTest:point withEvent:event];
}
//----------------------------




//ios7 ---------------------

- (CGSize)_preferredContentSize{
    return CGSizeMake([self calloutSize].width + 2,[self calloutSize].height+13 + 2);
}


- (UIView*)detailView{
    UIView* _calloutView = [self calloutView];
    return _calloutView;
}

- (void)setCalloutTitle:(NSString*)title{
    //DO NOTHING !
}

- (void)setCalloutSubtitle:(NSString*)title{
    //DO NOTHING !
}

- (NSString*)calloutTitle{
    return nil;
}

- (NSString*)calloutSubtitle{
    return nil;
}
//-------------------------


- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    if(!newSuperview || [CKOSVersion() floatValue] < 7 || !self.calloutView){
        return;
    }
    
    CGSize calloutSize = [self calloutSize];
    
     UIView* popoverView = [newSuperview superview];
    
    
    CLLocationCoordinate2D centerCoordinate = self.coordinate;
    CGPoint pointFromCenterCoordinate = [self.mapView convertCoordinate:centerCoordinate toPointToView:self.mapView];
    
    CGFloat xOffset = (calloutSize.width / 2) -  (popoverView.width + popoverView.x);
    CGPoint calloutcenter = CGPointMake(pointFromCenterCoordinate.x - xOffset, pointFromCenterCoordinate.y - (calloutSize.height / 2));
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:calloutcenter toCoordinateFromView:self.mapView];
    
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, self.mapView.region.span);
    [self.mapView setRegion:region animated:YES];
}

@end

@interface CKMapEmptyAnnotation : NSObject<MKAnnotation>
@property (nonatomic, assign, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end

@implementation CKMapEmptyAnnotation
@end

@interface CKAnnotationView()
@property(nonatomic,retain)UIViewController* calloutViewController;
@property(nonatomic,retain)CKCalloutView* calloutView;
@end

@implementation CKAnnotationView
@synthesize calloutViewController = _calloutViewController;
@synthesize annotationController = _annotationController;
@synthesize calloutViewControllerCreationBlock = _calloutViewControllerCreationBlock;

- (void)dealloc{
    [NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"CKAnnotationView_ios7_<%p>",self]];
    [self clearBindingsContext];
    [_calloutViewController release];
    _calloutViewController = nil;
    [_calloutViewControllerCreationBlock release];
    _calloutViewControllerCreationBlock = nil;
    [_calloutView release];
    _calloutView = nil;
    [super dealloc];
}

- (CKMapCollectionViewController*)mapController{
    return (CKMapCollectionViewController*)[_annotationController containerController];
}

- (MKMapView*)mapView{
    return [[self mapController] mapView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(_calloutViewControllerCreationBlock){
        if(selected){
            if([CKOSVersion() floatValue] >= 7){
                CGSize calloutSize = [self calloutViewControllerSize];
                
    
                
                CLLocationCoordinate2D centerCoordinate = self.annotation.coordinate;
                CGPoint pointFromCenterCoordinate = [self.mapView convertCoordinate:centerCoordinate toPointToView:self.mapView];
                
                CGFloat xOffset = 0;//(calloutSize.width / 2) -  (popoverView.width + popoverView.x);
                CGPoint calloutcenter = CGPointMake(pointFromCenterCoordinate.x - xOffset, pointFromCenterCoordinate.y - (calloutSize.height / 2));
                CLLocationCoordinate2D coordinate = [self.mapView convertPoint:calloutcenter toCoordinateFromView:self.mapView];
                
                MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, self.mapView.region.span);
                [self.mapView setRegion:region animated:YES];

            }
            
        }else{
            [_calloutViewController viewWillDisappear:YES];
            [_calloutViewController.view removeFromSuperview];
            [_calloutViewController viewDidDisappear:YES];
            
            [self clearBindingsContext];
            self.calloutViewController = nil;
            self.calloutView = nil;
        }
    }
}

- (UIViewController*)calloutViewController{
    if(_calloutViewController == NULL){
        _calloutViewController = [_calloutViewControllerCreationBlock(self.annotationController,self) retain];
        UIView* view = _calloutViewController.view;//force to load the view here !
        
      // if([CKOSVersion() floatValue] < 7){
            view.autoresizingMask = UIViewAutoresizingNone;
       //}else{
           // view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
       // }
        
        CGSize size = _calloutViewController.contentSizeForViewInPopover;
        if([_calloutViewController isKindOfClass:[UINavigationController class]]){
            UINavigationController* nav = (UINavigationController*)_calloutViewController;
            size = nav.topViewController.contentSizeForViewInPopover;
        }
        view.width = size.width;
        view.height = size.height;
        [view layoutSubviews];
        
        __unsafe_unretained CKAnnotationView* bself = self;
        
        [self beginBindingsContextByRemovingPreviousBindings];
        if([_calloutViewController isKindOfClass:[UINavigationController class]]){
            UINavigationController* nav = (UINavigationController*)_calloutViewController;
            [nav bind:@"contentSizeForViewInPopover" withBlock:^(id value) {
                CGSize size = _calloutViewController.contentSizeForViewInPopover;
                if([_calloutViewController isKindOfClass:[UINavigationController class]]){
                    UINavigationController* nav = (UINavigationController*)_calloutViewController;
                    size = nav.topViewController.contentSizeForViewInPopover;
                }
                
                view.width = size.width;
                view.height = size.height;
                [view layoutSubviews];
                
                if(bself.calloutView){
                    [bself.calloutView setCalloutSize:size];
                }
            }];
        }else{
            [_calloutViewController bind:@"contentSizeForViewInPopover" withBlock:^(id value) {
                CGSize size = _calloutViewController.contentSizeForViewInPopover;
                
                view.width = size.width;
                view.height = size.height;
                [view layoutSubviews];
                
                if(bself.calloutView){
                    [bself.calloutView setCalloutSize:size];
                }
            }];
        }
        [self endBindingsContext];
        
        
        [_calloutViewController viewWillAppear:YES];
        
        //In case size changes in viewWillAppear
        size = _calloutViewController.contentSizeForViewInPopover;
        if([_calloutViewController isKindOfClass:[UINavigationController class]]){
            UINavigationController* nav = (UINavigationController*)_calloutViewController;
            size = nav.topViewController.contentSizeForViewInPopover;
        }
        view.width = size.width;
        view.height = size.height;
        [view layoutSubviews];
    }
    return _calloutViewController;
}

- (CGSize)calloutViewControllerSize{
    CGSize size = self.calloutViewController.contentSizeForViewInPopover;
    if([self.calloutViewController isKindOfClass:[UINavigationController class]]){
        UINavigationController* nav = (UINavigationController*)_calloutViewController;
        size = nav.topViewController.contentSizeForViewInPopover;
    }
    return size;
}

- (void)didAddSubview:(UIView *)subview{
    if([CKOSVersion() floatValue] >= 7){
        if(_calloutViewControllerCreationBlock){
            __unsafe_unretained CKAnnotationView* bself = self;
            for(UIView* subsubview in subview.subviews){
                if ([[[subsubview class] description] isEqualToString:@"_MKPopoverEmbeddingView"]) {
                    
                    [NSObject beginBindingsContext:[NSString stringWithFormat:@"CKAnnotationView_ios7_<%p>",self] policy:CKBindingsContextPolicyRemovePreviousBindings];
                    [subsubview bind:@"windowDelegate" withBlock:^(id value) {
                        if(!value)
                            return;
                        
                        id windowdelegate = value;
                        if(windowdelegate){
                            id popoverController = [windowdelegate valueForKey:@"popoverController"];
                            if(popoverController){
                                CGSize size = [bself calloutViewControllerSize];
                                CGSize popoverContentSize = CGSizeMake(size.width + 2, size.height + 2);
                                [popoverController setValue:[NSValue valueWithCGSize:popoverContentSize] forKey:@"popoverContentSize"];
                                
                                id contentViewController = [popoverController valueForKey:@"contentViewController"];
                                if(contentViewController){
                                    [contentViewController setValue:[NSValue valueWithCGSize:popoverContentSize] forKey:@"contentSizeForViewInPopover"];
                                    
                                    UIView* smallCalloutView = [contentViewController valueForKey:@"view"];
                                    object_setClass(smallCalloutView,[CKCalloutView class]);
                                    
                                    CKCalloutView* v = (CKCalloutView*)smallCalloutView;
                                    bself.calloutView = v;
                                    
                                    if(self.calloutViewController){//view will appear has already been called !
                                        
                                        UIView* view = [_calloutViewController view];
                                        
                                        v.mapView = [self mapView];
                                        v.coordinate = self.annotation.coordinate;
                                        v.calloutSize = _calloutViewController.contentSizeForViewInPopover;
                                        v.calloutView = view;
                                        
                                        [smallCalloutView addSubview:view];
                                        [_calloutViewController viewDidAppear:YES];
                                    
                                    }
                                }
                            }
                        }
                        
                        [NSObject removeAllBindingsForContext:[NSString stringWithFormat:@"CKAnnotationView_ios7_<%p>",self]];
                    }];
                }
            }
        }
    }else{
        
        if(_calloutViewControllerCreationBlock){
            if ([[[subview class] description] isEqualToString:@"UICalloutView"]) {
                object_setClass(subview,[CKCalloutView class]);
                
                CKCalloutView* v = (CKCalloutView*)subview;
                self.calloutView = v;
                
                if(self.calloutViewController){//view will appear has already been called !
                    
                    UIView* view = [_calloutViewController view];
                    
                    v.mapView = [self mapView];
                    v.coordinate = self.annotation.coordinate;
                    v.calloutSize = _calloutViewController.contentSizeForViewInPopover;
                    v.calloutView = view;
                    
                    [subview addSubview:view];
                    [_calloutViewController viewDidAppear:YES];
            
                }
            }
        }
    }
}

@end


@implementation CKMapAnnotationController {
	CKMapAnnotationStyle _style;
}

@synthesize style = _style;
@synthesize deselectionCallback = _deselectionCallback;

- (id)init{
	if (self = [super init]) {
      _style = CKMapAnnotationPin;
    }
	return self;
}

- (void)dealloc{
    [_deselectionCallback release];
    _deselectionCallback = nil;
    [super dealloc];
}

+ (CKMapAnnotationController*)annotationController{
    return [[[CKMapAnnotationController alloc]init]autorelease];
}

+ (CKMapAnnotationController*)annotationControllerWithName:(NSString*)name{
    CKMapAnnotationController* controller = [[[CKMapAnnotationController alloc]init]autorelease];
    controller.name = name;
    return controller;
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

#pragma mark CKCollectionCellController Implementation

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
