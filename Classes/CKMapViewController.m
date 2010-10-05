//
//  CKMapViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-08-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKMapViewController.h"

#import "CKLocalization.h"
#import "CKConstants.h"
#import "CKUIColorAdditions.h"
#import "CKDebug.h"

//

@implementation CKMapViewController

@synthesize annotations = _annotations;
@synthesize centerCoordinate = _centerCoordinate;
@synthesize mapView = _mapView;

- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate {
    if (self = [super init]) {
		if (annotations) _annotations = [annotations retain];
		_centerCoordinate = centerCoordinate;
    }
    return self;
}

- (void)dealloc {
	[_mapView release];
	[_annotations release];
	_mapView = nil;
	_annotations = nil;
    [super dealloc];
}

#pragma mark View Management

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithRGBValue:0xc1bfbb];	
	
	if (self.mapView == nil) {
		self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
		self.mapView.autoresizingMask = CKUIViewAutoresizingFlexibleAll;
		[self.view addSubview:self.mapView];		
	}

	self.mapView.delegate = self;
	self.mapView.centerCoordinate = self.centerCoordinate;
	[self.mapView addAnnotations:self.annotations];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	self.mapView.delegate = self;
	self.mapView.frame = self.view.bounds;
	self.mapView.showsUserLocation = YES;
	
	if (self.annotations == nil || self.annotations.count == 0) return;
	
	// Set the zoom for 1 entry
	if (self.annotations.count == 1) {
		NSObject<MKAnnotation> *annotation = [self.annotations lastObject];
		[self zoomToCenterCoordinate:annotation.coordinate animated:NO];
		return;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.mapView.showsUserLocation = NO;
	self.mapView.delegate = nil;
}

#pragma mark Public API

- (void)setAnnotations:(NSArray *)theAnnotations {
	if (self.mapView) {
		[self.mapView removeAnnotations:_annotations];
		[_annotations release];
		_annotations = [theAnnotations retain];
		[self.mapView addAnnotations:theAnnotations];
		return;
	}
	
	[_annotations release];
	_annotations = [theAnnotations retain];
}

- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	self.centerCoordinate = coordinate;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, 1000.0f, 1000.0f);
	region = [self.mapView regionThatFits:region];
	[self.mapView setRegion:region animated:animated];
}

- (void)zoomToRegionEnclosingAnnotations:(NSArray *)theAnnotations animated:(BOOL)animated {
	if (theAnnotations.count == 0) return;
	
	CLLocationCoordinate2D topLeft, bottomRight;
	topLeft.latitude = topLeft.longitude = bottomRight.latitude = bottomRight.longitude = 0;
	for (NSObject<MKAnnotation> *annotation in theAnnotations) {
		if (annotation.coordinate.latitude < topLeft.latitude || topLeft.latitude == 0) topLeft.latitude = annotation.coordinate.latitude;
		if (annotation.coordinate.longitude < topLeft.longitude || topLeft.longitude == 0) topLeft.longitude = annotation.coordinate.longitude;
		if (annotation.coordinate.latitude > bottomRight.latitude || bottomRight.latitude == 0) bottomRight.latitude = annotation.coordinate.latitude;
		if (annotation.coordinate.longitude > bottomRight.longitude || bottomRight.longitude == 0) bottomRight.longitude = annotation.coordinate.longitude;
	}
	
	CLLocationCoordinate2D southWest;
	CLLocationCoordinate2D northEast;
	
	southWest.latitude = MIN(topLeft.latitude, bottomRight.latitude);
	southWest.longitude = MIN(topLeft.longitude, bottomRight.longitude);
	northEast.latitude = MAX(topLeft.latitude, bottomRight.latitude);
	northEast.longitude = MAX(topLeft.longitude, bottomRight.longitude);
	
	CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
	CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];	
	
	// This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
	// FIXME: Triggers a "deprecation warning" but works on OS < 3.2
	CLLocationDistance meters = [locSouthWest getDistanceFrom:locNorthEast];
	MKCoordinateRegion region;
	region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
	region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
	region.span.latitudeDelta = meters / 111319.5;
	region.span.longitudeDelta = 0.009;

	region = [self.mapView regionThatFits:region];
	[self.mapView setRegion:region animated:animated];
	
	[locSouthWest release];
	[locNorthEast release];	
}

#pragma mark MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if (annotation == mapView.userLocation) 
		return nil;
	
	static NSString *annotationIdentifier = @"Annotation";
	
	MKPinAnnotationView *annView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	if (!annView) {
		annView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier] autorelease];
		annView.canShowCallout = YES;
	} else {
		annView.annotation = annotation;
	}
	
	return annView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	// If displaying only one entry, select it
	if (self.annotations && self.annotations.count == 1) {
		[self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];
	}	
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
	return;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	return;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	return;
}

@end