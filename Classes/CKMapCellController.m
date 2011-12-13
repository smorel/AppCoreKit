//
//  CKMapCellController.m
//  iPadMerchantView
//
//  Created by Fred Brunel on 10-05-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKMapCellController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKConstants.h"

@interface CKMapCellAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@implementation CKMapCellAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	if (self = [super init]) {
		_coordinate = coordinate;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	return _coordinate;
}

@end

//

@interface CKMapCellController ()
@property (nonatomic, retain) CKMapCellAnnotation *annotation;
@end

@implementation CKMapCellController

@synthesize annotation = _annotation;
@synthesize annotationImage = _annotationImage;
@synthesize annotationImageOffset = _annotationImageOffset;

- (void)postInit {
	self.annotationImageOffset = CGPointMake(0, 0);
}

- (id)init {
	self = [super init];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	if (self = [super init]) {
		self.annotation = [[[CKMapCellAnnotation alloc] initWithCoordinate:coordinate] autorelease];
		[self postInit];
	}
	return self;
}

- (void)cellDidDisappear {
	UITableViewCell *cell = self.tableViewCell;
	if (cell) {
		MKMapView *mapView = (MKMapView *)[cell.contentView viewWithTag:1000];
		mapView.delegate = nil;
	}
}

- (void)dealloc {
	self.annotation = nil;
	self.annotationImage = nil;
	[super dealloc];
}

//

- (void)initTableViewCell:(UITableViewCell*)cell{
	MKMapView *mapView = [[[MKMapView alloc] initWithFrame:cell.contentView.bounds] autorelease];
	mapView.tag = 1000;
	mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mapView.layer.cornerRadius = 10.0f;
	mapView.showsUserLocation = NO;
	mapView.userInteractionEnabled = NO;
	
	[cell.contentView addSubview:mapView];
}

- (void)setupCell:(UITableViewCell *)cell {
	MKMapView *mapView = (MKMapView *)[cell.contentView viewWithTag:1000];
	mapView.delegate = self;
    
    MKCoordinateSpan span;
	span.latitudeDelta = 0.0005;
	span.longitudeDelta = 0.0005;
	
	CLLocationCoordinate2D centerCoordinate;
	
	if (self.annotation) {
		[mapView addAnnotation:self.annotation];
		centerCoordinate = self.annotation.coordinate;
	}
	else if ([self.value conformsToProtocol:@protocol(MKAnnotation)]) {
		[mapView addAnnotation:self.value];
		centerCoordinate = [self.value coordinate];
	}
	
	MKCoordinateRegion region;
	region.center = centerCoordinate;
	region.span = span;
	[mapView setRegion:region animated:NO];
}

#pragma mark MKMapViewDelegate Protocol

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	static NSString *identifier = @"CKMapCellControllerAnnotation";
	
	MKAnnotationView *view = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (!view) {
		if (self.annotationImage) {
			view = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
			view.image = self.annotationImage;
			view.centerOffset = self.annotationImageOffset;
		} else {
			view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
		}
		view.canShowCallout = NO;
	} else {
		view.annotation = annotation;
	}
	
	return view;
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	return CKItemViewFlagNone;
}


+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	return [NSValue valueWithCGSize:CGSizeMake(100,260.0)];
}

@end
