//
//  CKMapCellController.m
//  iPadMerchantView
//
//  Created by Fred Brunel on 10-05-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKMapCellController.h"
#import <QuartzCore/QuartzCore.h>
#import <CloudKit/CKConstants.h>

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

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	if (self = [super init]) {
		self.annotation = [[[CKMapCellAnnotation alloc] initWithCoordinate:coordinate] autorelease];
		self.selectable = NO;
		self.annotationImageOffset = CGPointMake(0, 0);
		self.rowHeight = 260.0f;
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

- (UITableViewCell *)loadCell {
	UITableViewCell *cell = [self cellWithStyle:UITableViewCellStyleDefault];
	
	MKMapView *mapView = [[[MKMapView alloc] initWithFrame:cell.contentView.bounds] autorelease];
	mapView.tag = 1000;
	mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	mapView.layer.cornerRadius = 10.0f;
	mapView.showsUserLocation = NO;
	mapView.userInteractionEnabled = NO;
	
	[cell.contentView addSubview:mapView];

	MKCoordinateSpan span;
	span.latitudeDelta = 0.0005;
	span.longitudeDelta = 0.0005;
	
	MKCoordinateRegion region;
	region.center = self.annotation.coordinate;
	region.span = span;
	
	[mapView setRegion:region animated:NO];
	[mapView addAnnotation:self.annotation];
	
	return cell;
}

- (void)setupCell:(UITableViewCell *)cell {
	MKMapView *mapView = (MKMapView *)[cell.contentView viewWithTag:1000];
	mapView.delegate = self;
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

@end
