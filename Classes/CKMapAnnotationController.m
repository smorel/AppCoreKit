//
//  CKMapAnnotationController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKMapAnnotationController.h"
#import "CKNSValueTransformer+Additions.h"


@implementation CKMapAnnotationController

@synthesize style = _style;

- (id)init{
	[super init];
	_style = CKMapAnnotationPin;
	return self;
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
			theView = [[[MKAnnotationView alloc]initWithAnnotation:self.value reuseIdentifier:[self identifier]] autorelease];
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
	[super setupView:view];
}

- (void)rotateView:(UIView*)view withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateView:view withParams:params animated:animated];
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

@end
