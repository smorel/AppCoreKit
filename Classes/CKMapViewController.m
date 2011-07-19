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

#import "CKTableViewCellController.h"
#import "CKDocumentController.h"
#import "CKDocumentArray.h"
#import "CKItemViewController+StyleManager.h"

#import "CKNSNotificationCenter+Edition.h"


NSInteger compareLocations(id <MKAnnotation>obj1, id <MKAnnotation> obj2, void *context)
{
	CLLocationCoordinate2D* centerCoordinate = (CLLocationCoordinate2D*)context;
	
	CLLocation *centerLoc = [[CLLocation alloc] initWithLatitude:centerCoordinate->latitude longitude:centerCoordinate->longitude];
	CLLocation *obj1Loc = [[CLLocation alloc] initWithLatitude:obj1.coordinate.latitude longitude:obj1.coordinate.longitude];
	CLLocation *obj2Loc = [[CLLocation alloc] initWithLatitude:obj2.coordinate.latitude longitude:obj2.coordinate.longitude];
	
	CLLocationDistance dist1 = [obj1Loc distanceFromLocation:centerLoc];
	CLLocationDistance dist2 = [obj2Loc distanceFromLocation:centerLoc];
	
    if (dist1 <dist2)
        return NSOrderedAscending;
    else if (dist1 > dist2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


//
@interface CKMapViewController()
- (void)onPropertyChanged:(NSNotification*)notification;
- (void)zoom:(BOOL)animated;
@property (nonatomic, retain) id nearestAnnotation;
@end


@implementation CKMapViewController

@synthesize centerCoordinate = _centerCoordinate;
@synthesize mapView = _mapView;
@synthesize zoomStrategy = _zoomStrategy;
@synthesize smartZoomDefaultRadius = _smartZoomDefaultRadius;
@synthesize smartZoomMinimumNumberOfAnnotations = _smartZoomMinimumNumberOfAnnotations;
@synthesize annotationToSelect = _annotationToSelect;
@synthesize nearestAnnotation = _nearestAnnotation;

- (void)postInit {
	[super postInit];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPropertyChanged:) name:CKEditionPropertyChangedNotification object:nil];
	
	_zoomStrategy = CKMapViewControllerZoomStrategyEnclosing;
	_smartZoomMinimumNumberOfAnnotations = 3;
	_smartZoomDefaultRadius = 1000;
}

- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate {
	self = [super init];
    if (self) {
		CKDocumentArray* collection = [[CKDocumentArray alloc]init];
		[collection addObjectsFromArray:annotations];
		
		self.objectController = [[[CKDocumentController alloc]initWithCollection:collection]autorelease];
		
		_centerCoordinate = centerCoordinate;
		[self postInit];
    }
    return self;
}

- (void)dealloc {
	[_mapView release];
	_mapView = nil;
	[_annotationToSelect release];
	_annotationToSelect = nil;
	[_nearestAnnotation release];
	_nearestAnnotation = nil;
    [super dealloc];
}

#pragma Params Management

- (void)updateParams{
	
	if(self.params == nil){
		self.params = [NSMutableDictionary dictionary];
	}
	
	[self.params setObject:[NSValue valueWithCGSize:self.view.bounds.size] forKey:CKTableViewAttributeBounds];
	[self.params setObject:[NSNumber numberWithInt:self.interfaceOrientation] forKey:CKTableViewAttributeInterfaceOrientation];
	[self.params setObject:[NSNumber numberWithBool:YES] forKey:CKTableViewAttributePagingEnabled];//NOT SUPPORTED
	[self.params setObject:[NSNumber numberWithInt:CKTableViewOrientationLandscape] forKey:CKTableViewAttributeOrientation];//NOT SUPPORTED
	[self.params setObject:[NSNumber numberWithDouble:0] forKey:CKTableViewAttributeAnimationDuration];
	[self.params setObject:[NSNumber numberWithBool:NO] forKey:CKTableViewAttributeEditable];//NOT SUPPORTED
	[self.params setObject:[NSValue valueWithNonretainedObject:self] forKey:CKTableViewAttributeParentController];
}

#pragma mark View Management

- (void)addAnnotations:(NSArray*)annotations{
	[self.mapView addAnnotations:annotations];
}

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
	[self addAnnotations:self.annotations];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	self.mapView.delegate = self;
	self.mapView.frame = self.view.bounds;
	//self.mapView.showsUserLocation = YES;
	
	[self updateParams];
	[self updateVisibleViewsRotation];
		
	[self reloadData:NO];
	
	for(int i =0; i< [self numberOfSections];++i){
		[self fetchMoreIfNeededAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
	}
}


-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.mapView.showsUserLocation = NO;
	self.mapView.delegate = nil;
}

#pragma mark Annotations

- (void)setAnnotations:(NSArray *)theAnnotations {
	CKDocumentController* documentController = nil;
	if([self.objectController isKindOfClass:[CKDocumentController class]]){
		documentController = (CKDocumentController*)self.objectController;
	}
	else{
		CKDocumentArray* collection = [[CKDocumentArray alloc]init];
		self.objectController = [[[CKDocumentController alloc]initWithCollection:collection]autorelease];
		if([self isViewLoaded] && [self.view superview] != nil){
			if([self.objectController respondsToSelector:@selector(setDelegate:)]){
				[self.objectController performSelector:@selector(setDelegate:) withObject:self];
			}
		}
	}
	
	[documentController.collection removeAllObjects];
	[documentController.collection addObjectsFromArray:theAnnotations];
}

- (NSArray*)annotations{
	return [self objectsForSection:0];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate{
	_centerCoordinate = coordinate;
	[self.mapView setCenterCoordinate:coordinate animated:([self isViewLoaded] && [self.view superview] != nil)];
}
														   

#pragma mark Location Management

- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	self.centerCoordinate = coordinate;
	MKCoordinateRegion region = self.mapView.region;
	region.center = coordinate;
	region = [self.mapView regionThatFits:region];
	[self.mapView setRegion:region animated:animated];
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
	CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
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



- (void)smartZoomWithAnnotations:(NSArray *)annotations animated:(BOOL)animated{
	self.nearestAnnotation = nil;
	NSArray* orderedByDistance = [annotations sortedArrayUsingFunction:&compareLocations context:&_centerCoordinate];
	NSMutableArray* theAnnotations = [NSMutableArray array];
	for (NSObject<MKAnnotation> *annotation in orderedByDistance) {
		[theAnnotations addObject:annotation];
		if(annotation.coordinate.latitude != _centerCoordinate.latitude
		   && annotation.coordinate.longitude != _centerCoordinate.longitude
		   && _nearestAnnotation == nil){
			self.nearestAnnotation = annotation;
		}
		if([theAnnotations count] >= _smartZoomMinimumNumberOfAnnotations)
			break;
		
	}
	
	if([theAnnotations count] > 0){
		if(self.annotationToSelect != nil){
			[theAnnotations addObject:self.annotationToSelect];
		}
		[self zoomToRegionEnclosingAnnotations:theAnnotations animated:animated];
	}
	else{
		MKCoordinateRegion region;
		region.center.latitude = _centerCoordinate.latitude;
		region.center.longitude = _centerCoordinate.longitude;
		region.span.latitudeDelta = _smartZoomDefaultRadius / 111319.5;
		region.span.longitudeDelta = 0.009;
		
		region = [self.mapView regionThatFits:region];
		[self.mapView setRegion:region animated:animated];
	}
}


- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapViewControllerZoomStrategy)strategy animated:(BOOL)animated{
	switch(strategy){
		case CKMapViewControllerZoomStrategySmart:{
			[self smartZoomWithAnnotations:annotations animated:animated];
			break;
		}
		case CKMapViewControllerZoomStrategyEnclosing:{
			[self zoomToRegionEnclosingAnnotations:annotations animated:animated];
			break;
		}
	}
}

- (void)zoom:(BOOL)animated{
	[self zoomOnAnnotations:self.mapView.annotations withStrategy:self.zoomStrategy animated:animated];
}

- (void)setAnnotationToSelect:(id<MKAnnotation>)annotation{
	[_annotationToSelect release];
	if(annotation.coordinate.latitude != 0 && annotation.coordinate.longitude != 0){
		_annotationToSelect = [annotation retain];
	}
	else{
		_annotationToSelect = nil;
	}
}

#pragma mark MKMapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
	if(self.annotationToSelect != nil && [self.mapView.annotations containsObject:_annotationToSelect]){
		[self.mapView selectAnnotation:self.annotationToSelect animated:YES];
	}
	else if(self.nearestAnnotation != nil){
		[self.mapView selectAnnotation:self.nearestAnnotation animated:YES];
	}
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
}

- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier{
	return [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if (annotation == mapView.userLocation) 
		return nil;
	
	NSInteger index = [self indexOfObject:annotation inSection:0];
	UIView* view = [self createViewAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	if(view == nil){
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
	
	NSAssert([view isKindOfClass:[MKAnnotationView class]],@"invalid type for view");
	return (MKAnnotationView*)view;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	// If displaying only one entry, select it
	if (self.annotations && self.annotations.count == 1) {
		[self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];
	}	
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	[self didSelectAccessoryViewAtIndexPath:[self indexPathForView:view]];
}
	 
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
	[self didSelectViewAtIndexPath:[self indexPathForView:view]];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
	//TODO
}

/*
 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
 
 - (void)mapViewWillStartLoadingMap:(MKMapView *)mapView;
 - (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error;
 
 
 //OS4 only
 - (void)mapViewWillStartLocatingUser:(MKMapView *)mapView ;
 - (void)mapViewDidStopLocatingUser:(MKMapView *)mapView ;
 - (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation;
 - (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error;
 
 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState 
 fromOldState:(MKAnnotationViewDragState)oldState ;
 
 - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay;
 
 // Called after the provided overlay views have been added and positioned in the map.
 - (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews;
 */

#pragma mark CKObjectControllerDelegate

- (void)onReload{
	[self reloadData];
}

- (void)onBeginUpdates{
	//To implement in inherited class
}

- (void)onEndUpdates{
}

- (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	[self addAnnotations:objects];
	[self zoom:YES];
}

- (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	[self.mapView removeAnnotations:objects];
	[self zoom:YES];
}

- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	id object = [self objectAtIndexPath:indexPath];
	return [self.mapView viewForAnnotation:object];
}

- (NSArray*)visibleViews{
	NSMutableArray* array = [NSMutableArray array];
	NSInteger count = [self numberOfObjectsForSection:0];
	for(int i=0;i<count;++i){
		UIView* view = [self viewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		if(view != nil){
			[array addObject:view];
		}
	}
	return array;
}

- (BOOL)reloadData{
	return [self reloadData:YES];
}

- (BOOL)reloadData:(BOOL)animated{
	CKFeedSource* source = [self collectionDataSource];
	if ((source != nil) && source.isFetching) {
		//return NO;
	}
	
	[self.mapView removeAnnotations:self.mapView.annotations];
	NSArray* objects = [self objectsForSection:0];
	[self addAnnotations:objects];

	[self zoom:YES];
	 // Set the zoom for 1 entry
	 /*if (self.annotations.count == 1) {
	 NSObject<MKAnnotation> *annotation = [self.annotations lastObject];
	 [self zoomToCenterCoordinate:annotation.coordinate animated:NO];
	 }*/
	return YES;

}

- (void)onPropertyChanged:(NSNotification*)notification{
	NSArray* objects = [self objectsForSection:0];
	CKObjectProperty* property = [notification objectProperty];
	if([objects containsObject:property.object] == YES){
		[self reloadData];
		return;
	}
}

@end