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
#import "CKTableViewCellController+StyleManager.h"

//

@interface CKMapViewController ()
@property (nonatomic, retain) NSMutableDictionary* cellsToControllers;
@property (nonatomic, retain) NSMutableDictionary* params;

- (CKTableViewCellController*)controllerForRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)notifiesCellControllersForVisibleRows;
- (CKItemViewFlags)flagsForRowAtIndexPath:(NSIndexPath*)indexPath;

- (void)updateParams;

@end


@implementation CKMapViewController

@synthesize annotations = _annotations;
@synthesize centerCoordinate = _centerCoordinate;
@synthesize mapView = _mapView;

@synthesize objectController = _objectController;
@synthesize controllerFactory = _controllerFactory;
@synthesize cellsToControllers = _cellsToControllers;
@synthesize params = _params;

- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate {
    if (self = [super init]) {
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
	[_params release];
	_params = nil;
	[_objectController release];
	_objectController = nil;
	[_controllerFactory release];
	_controllerFactory = nil;
	[_cellsToControllers release];
	_cellsToControllers = nil;
    [super dealloc];
}

- (void)postInit{
	self.cellsToControllers = [NSMutableDictionary dictionary];
}

- (id)initWithCoder:(NSCoder *)decoder {
	[super initWithCoder:decoder];
	[self postInit];
	return self;
}

- (id)init {
    if (self = [super init]) {
		[self postInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		[self postInit];
	}
	return self;
}

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings{
	CKDocumentController* controller = [[[CKDocumentController alloc]initWithCollection:collection]autorelease];
	CKObjectViewControllerFactory* factory = [CKObjectViewControllerFactory factoryWithMappings:mappings];
	[self initWithObjectController:controller withControllerFactory:factory];
	return self;
}

- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory{
	[self init];
	self.objectController = controller;
	self.controllerFactory = factory;
	
	return self;
}

#pragma mark Controller Factory & Object Controller Management

- (void)setObjectController:(id)controller{
	//if(_objectController && [_objectController conformsToProtocol:@protocol(CKObjectController)]){
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
	//}
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:nil];
	}
	
	
	[_objectController release];
	_objectController = [controller retain];
	
	if([self.view window] && [controller respondsToSelector:@selector(setDelegate:)]){
		[controller performSelector:@selector(setDelegate:) withObject:self];
	}
	
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
	
	if(controller && [controller isKindOfClass:[CKDocumentController class]]){
		CKDocumentController* documentController = (CKDocumentController*)controller;
		documentController.displayFeedSourceCell = NO;
	}
}

- (void)setControllerFactory:(id)factory{
	if([_controllerFactory respondsToSelector:@selector(setObjectController:)]){
		[_controllerFactory performSelector:@selector(setObjectController:) withObject:nil];
	}
	
	[_controllerFactory release];
	_controllerFactory = [factory retain];
	
	if([factory respondsToSelector:@selector(setObjectController:)]){
		[factory performSelector:@selector(setObjectController:) withObject:_objectController];
	}
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
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:self];
	}
	
	[super viewWillAppear:animated];
		
	self.mapView.delegate = self;
	self.mapView.frame = self.view.bounds;
	self.mapView.showsUserLocation = YES;
	
	[self updateParams];
	
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
			[controller rotateCell:cell withParams:self.params animated:YES];
		}
	}	
	
	/*
	// Set the zoom for 1 entry
	if (self.annotations.count == 1) {
		NSObject<MKAnnotation> *annotation = [self.annotations lastObject];
		[self zoomToCenterCoordinate:annotation.coordinate animated:NO];
		return;
	}
	 */
	[self reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self notifiesCellControllersForVisibleRows];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.mapView.showsUserLocation = NO;
	self.mapView.delegate = nil;
	
	if([_objectController respondsToSelector:@selector(setDelegate:)]){
		[_objectController performSelector:@selector(setDelegate:) withObject:nil];
	}
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		if(controller && [controller respondsToSelector:@selector(cellDidDisappear)]){
			[controller cellDidDisappear];
		}
	}
}

#pragma mark Rotation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	[self updateParams];
	for(NSValue* cellValue in [_cellsToControllers allKeys]){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:cellValue];
		UITableViewCell* cell = [cellValue nonretainedObjectValue];
		
		if([controller respondsToSelector:@selector(rotateCell:withParams:animated:)]){
			[self.params setObject:[NSNumber numberWithDouble:duration] forKey:CKTableViewAttributeAnimationDuration];
			[controller rotateCell:cell withParams:self.params animated:YES];
		}
	}
	[self notifiesCellControllersForVisibleRows];
	
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	[self notifiesCellControllersForVisibleRows];
}

#pragma mark Annotations

- (void)setAnnotations:(NSArray *)theAnnotations {
	/*CKDocumentController* documentController = nil
	if([self.objectController isKindOfClass:[CKDocumentController class]]){
		documentController = (CKDocumentController*)self.objectController
	}
	else{
		CKDocumentArray* collection = [[CKDocumentArray alloc]init];
		self.objectController = [[[CKDocumentController alloc]initWithCollection:collection]autorelease];
		if([self isViewLoaded] && [self.view superview] != nil){
			if([_objectController respondsToSelector:@selector(setDelegate:)]){
				[_objectController performSelector:@selector(setDelegate:) withObject:self];
			}
		}
	}
	
	[documentController.collection addObjectsFromArray:theAnnotations];*/
}

- (NSArray*)annotations{
	if([self.objectController isKindOfClass:[CKDocumentController class]]){
		CKDocumentController* documentController = (CKDocumentController*)_objectController;
		return [documentController.collection allObjects];
	}
	return nil;
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

/*
 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
 - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;
 
 - (void)mapViewWillStartLoadingMap:(MKMapView *)mapView;
 - (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView;
 - (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error;
 
 // mapView:viewForAnnotation: provides the view for each annotation.
 // This method may be called for all or some of the added annotations.
 // For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.
 - (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
 
 // mapView:didAddAnnotationViews: is called after the annotation views have been added and positioned in the map.
 // The delegate can implement this method to animate the adding of the annotations views.
 // Use the current positions of the annotation views as the destinations of the animation.
 - (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views;
 
 // mapView:annotationView:calloutAccessoryControlTapped: is called when the user taps on left & right callout accessory UIControls.
 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
 
 //OS4 only
 - (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view ;
 - (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view;
 
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

- (void)objectControllerReloadData:(id)controller{
	[self reloadData];
	[self notifiesCellControllersForVisibleRows];
}

- (void)objectControllerDidBeginUpdating:(id)controller{
	//NOT SUPPORTED
}

- (void)objectControllerDidEndUpdating:(id)controller{
	[self reloadData];
}

- (void)objectController:(id)controller insertObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	//NOT SUPPORTED dynamic insertion
}

- (void)objectController:(id)controller removeObject:(id)object atIndexPath:(NSIndexPath*)indexPath{
	//NOT SUPPORTED dynamic deletion
}

- (void)objectController:(id)controller insertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	//NOT SUPPORTED dynamic insertion
}

- (void)objectController:(id)controller removeObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	//NOT SUPPORTED dynamic deletion
}

#pragma mark Private API

- (CKTableViewCellController*)controllerForRowAtIndexPath:(NSIndexPath*)indexPath{
	id object = [_objectController objectAtIndexPath:indexPath];
	MKAnnotationView * view = [_mapView viewForAnnotation:object];
	if(view){
		CKTableViewCellController* controller = [_cellsToControllers objectForKey:[NSValue valueWithNonretainedObject:view]];
		return controller;
	}
	return nil;
}

- (void)notifiesCellControllersForVisibleRows {
	/*NSArray *visibleIndexPaths = [self.carouselView visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		UIView* view = [self.carouselView viewAtIndexPath:indexPath];
		NSAssert([view isKindOfClass:[UITableViewCell class]],@"Works with CKTableViewCellController YET");
		UITableViewCell* cell = (UITableViewCell*)view;
		[[self controllerForRowAtIndexPath:indexPath] cellDidAppear:cell];
	}*/
}

- (CKItemViewFlags)flagsForRowAtIndexPath:(NSIndexPath*)indexPath{
	CKItemViewFlags flags = [self.controllerFactory flagsForControllerIndexPath:indexPath params:self.params];
	return flags;
}

- (void)reloadData{
}

@end