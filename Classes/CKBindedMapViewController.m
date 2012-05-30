//
//  CKBindedMapViewController.m
//  CloudKit
//
//  Created by Olivier Collet on 10-08-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKBindedMapViewController.h"

#import "CKLocalization.h"
#import "CKUIViewAutoresizing+Additions.h"
#import "CKUIColor+Additions.h"
#import "CKDebug.h"

#import "CKTableViewCellController.h"
#import "CKCollectionController.h"
#import "CKArrayCollection.h"

#import "CKNSNotificationCenter+Edition.h"


NSInteger compareLocations(id <MKAnnotation>obj1, id <MKAnnotation> obj2, void *context)
{
	CLLocationCoordinate2D* centerCoordinate = (CLLocationCoordinate2D*)context;
	
	CLLocation *centerLoc = [[[CLLocation alloc] initWithLatitude:centerCoordinate->latitude longitude:centerCoordinate->longitude]autorelease];
	CLLocation *obj1Loc = [[[CLLocation alloc] initWithLatitude:obj1.coordinate.latitude longitude:obj1.coordinate.longitude]autorelease];
	CLLocation *obj2Loc = [[[CLLocation alloc] initWithLatitude:obj2.coordinate.latitude longitude:obj2.coordinate.longitude]autorelease];
	
	CLLocationDistance dist1 = [obj1Loc distanceFromLocation:centerLoc];
	CLLocationDistance dist2 = [obj2Loc distanceFromLocation:centerLoc];
	
    if (dist1 <dist2)
        return NSOrderedAscending;
    else if (dist1 > dist2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}


@interface CKMapView : MKMapView
@property(nonatomic,retain) id<MKAnnotation> annotationToSelectAfterScrolling;
@end

@implementation CKMapView
@synthesize annotationToSelectAfterScrolling = _annotationToSelectAfterScrolling;

- (void)dealloc{
    [_annotationToSelectAfterScrolling release];
    _annotationToSelectAfterScrolling = nil;
    [super dealloc];
}

- (void)selectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated{
    MKAnnotationView* view = [self viewForAnnotation:annotation];
    if(self.annotationToSelectAfterScrolling == annotation){
        BOOL hasCalloutView = NO;
        for(UIView* v in [view subviews]){
            if([[[v class]description] isEqualToString:@"UICalloutView"]
               ||[[[v class]description] isEqualToString:@"CKCalloutView"]){
                hasCalloutView = YES;
                break;
            }
        }
        //if no calloutview in view && view is selected, select nil non animated !
        if(view.selected && !hasCalloutView){
            [super deselectAnnotation:annotation animated:NO];
        }
                             
        [super selectAnnotation:annotation animated:animated];
        self.annotationToSelectAfterScrolling = nil;
        return;
    }
    
    BOOL delayedCallToSuper = NO;
    if([view isKindOfClass:[CKAnnotationView class]]){
        CKAnnotationView* customView = (CKAnnotationView*)view;
        if(customView.calloutViewController){
            delayedCallToSuper = YES;
            self.annotationToSelectAfterScrolling = annotation;
            [self setCenterCoordinate:annotation.coordinate animated:YES];
        }
    }
    
    if(!delayedCallToSuper){
        [super selectAnnotation:annotation animated:animated];
    }
}

@end


//
@interface CKBindedMapViewController()
- (void)onPropertyChanged:(NSNotification*)notification;
- (void)zoom:(BOOL)animated;
@property (nonatomic, retain) id nearestAnnotation;
@property (nonatomic, assign) BOOL mapViewHasBeenReloaded;
@end


@implementation CKBindedMapViewController

@synthesize centerCoordinate = _centerCoordinate;
@synthesize mapView = _mapView;
@synthesize zoomStrategy = _zoomStrategy;
@synthesize smartZoomDefaultRadius = _smartZoomDefaultRadius;
@synthesize smartZoomMinimumNumberOfAnnotations = _smartZoomMinimumNumberOfAnnotations;
@synthesize annotationToSelect = _annotationToSelect;
@synthesize nearestAnnotation = _nearestAnnotation;
@synthesize includeUserLocationWhenZooming = _includeUserLocationWhenZooming;
@synthesize selectionBlock = _selectionBlock;
@synthesize deselectionBlock = _deselectionBlock;
@synthesize selectionStrategy = _selectionStrategy;
@synthesize didScrollBlock = _didScrollBlock;
@synthesize mapViewHasBeenReloaded = _mapViewHasBeenReloaded;

- (void)postInit {
	[super postInit];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPropertyChanged:) name:CKEditionPropertyChangedNotification object:nil];
	
	_zoomStrategy = CKBindedMapViewControllerZoomStrategyEnclosing;
    _selectionStrategy = CKBindedMapViewControllerSelectionStrategyAutoSelectAloneAnnotations;
	_smartZoomMinimumNumberOfAnnotations = 3;
	_smartZoomDefaultRadius = 1000;
    _includeUserLocationWhenZooming = YES;
    _mapViewHasBeenReloaded = NO;
    
    if(!self.controllerFactory){
        CKItemViewControllerFactory* factory = [CKItemViewControllerFactory factory];
        [factory addItemForObjectOfClass:[NSObject class] withControllerCreationBlock:^CKItemViewController *(id object, NSIndexPath *indexPath) {
            CKMapAnnotationController* controller = [[[CKMapAnnotationController alloc]init]autorelease];
            [controller setSetupCallback:[CKCallback callbackWithBlock:^id(id value) {
                CKMapAnnotationController* controller = (CKMapAnnotationController*)value;
                MKAnnotationView* annotationView = (MKAnnotationView*)controller.view;
                annotationView.annotation = [controller value];
                return (id)nil;
            }]];
            return controller;
        }];
        self.controllerFactory = factory;
    }
}

- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate {
	self = [super init];
    if (self) {
		CKArrayCollection* collection = [[CKArrayCollection alloc]init];
		[collection addObjectsFromArray:annotations];
		
		self.objectController = [[[CKCollectionController alloc]initWithCollection:collection]autorelease];
        [collection release];
		
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
    [_selectionBlock release];
    _selectionBlock = nil;
    [_deselectionBlock release];
    _deselectionBlock = nil;
    [_didScrollBlock release];
    _didScrollBlock = nil;
    [super dealloc];
}

#pragma mark View Management

- (void)addAnnotations:(NSArray*)annotations{
	[self.mapView addAnnotations:annotations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithRGBValue:0xc1bfbb];	
	
	if (self.mapView == nil) {
		self.mapView = [[[CKMapView alloc] initWithFrame:self.view.bounds] autorelease];
		self.mapView.autoresizingMask = UIViewAutoresizingFlexibleAll;
		[self.view addSubview:self.mapView];		
	}

	self.mapView.delegate = self;
    
    if([self.annotations count] > 0 || (self.centerCoordinate.latitude != 0 && self.centerCoordinate.longitude != 0)){
        self.mapView.centerCoordinate = self.centerCoordinate;
        [self addAnnotations:self.annotations];
    }else{
        [self.mapView setVisibleMapRect:MKMapRectWorld];
    }
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
	
    [self updateVisibleViewsRotation];
    
    if(!self.mapViewHasBeenReloaded){
        self.mapViewHasBeenReloaded = YES;
        [self reloadData];
    }
	
	for(int i =0; i< [self numberOfSections];++i){
		[self fetchMoreIfNeededAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
	}
}


-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//self.mapView.showsUserLocation = NO;
	self.mapView.delegate = nil;
}

#pragma mark Annotations

- (void)setAnnotations:(NSArray *)theAnnotations {
	CKCollectionController* documentController = nil;
	if([self.objectController isKindOfClass:[CKCollectionController class]]){
		documentController = (CKCollectionController*)self.objectController;
	}
	else{
		CKArrayCollection* collection = [[[CKArrayCollection alloc]init]autorelease];
		self.objectController = [[[CKCollectionController alloc]initWithCollection:collection]autorelease];
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

- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius animated:(BOOL)animated {
	self.centerCoordinate = coordinate;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius, radius);
	region = [self.mapView regionThatFits:region];
	[self.mapView setRegion:region animated:animated];
}

- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	[self zoomToCenterCoordinate:coordinate radius:500.0f animated:animated];
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


- (void)animatedZoomToRegionEnclosingAnnotations:(NSArray *)annotations {
    [self zoomToRegionEnclosingAnnotations:annotations animated:YES];
}

- (void)notAnimatedZoomToRegionEnclosingAnnotations:(NSArray *)annotations {
    [self zoomToRegionEnclosingAnnotations:annotations animated:NO];
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
		
        if(animated)
            [self performSelector:@selector(animatedZoomToRegionEnclosingAnnotations:) withObject:theAnnotations afterDelay:0.0];
        else
            [self performSelector:@selector(notAnimatedZoomToRegionEnclosingAnnotations:) withObject:theAnnotations afterDelay:0.0];
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


- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKBindedMapViewControllerZoomStrategy)strategy animated:(BOOL)animated{
    NSMutableArray* theAnnotations = [NSMutableArray arrayWithArray:annotations];
    if(!self.includeUserLocationWhenZooming && self.mapView.userLocation){
        NSInteger index = [theAnnotations indexOfObjectIdenticalTo:self.mapView.userLocation];
        while(index != NSNotFound){
            [theAnnotations removeObjectAtIndex:index];
            index = [theAnnotations indexOfObjectIdenticalTo:self.mapView.userLocation];
        }
    }
    
	switch(strategy){
		case CKBindedMapViewControllerZoomStrategySmart:{
			[self smartZoomWithAnnotations:theAnnotations animated:animated];
			break;
		}
		case CKBindedMapViewControllerZoomStrategyEnclosing:{
			[self zoomToRegionEnclosingAnnotations:theAnnotations animated:animated];
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
    CKMapView* ckMapView = (CKMapView*)mapView;
    if(ckMapView.annotationToSelectAfterScrolling){
        id<MKAnnotation> annotation = ckMapView.annotationToSelectAfterScrolling;
		[self.mapView selectAnnotation:annotation animated:YES];
    }
    
	if(self.annotationToSelect != nil && [self.mapView.annotations containsObject:_annotationToSelect]){
		[self.mapView selectAnnotation:self.annotationToSelect animated:YES];
	}
	else if(self.nearestAnnotation != nil){
		[self.mapView selectAnnotation:self.nearestAnnotation animated:YES];
	}
    
    if(_didScrollBlock){
        _didScrollBlock(self,animated);
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
    if(index == NSNotFound)
        return nil;
    
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

- (void)selectLastAnnotation {
    if([self.annotations count] > 0){
        [self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	// If displaying only one entry, select it
    if(_selectionStrategy == CKBindedMapViewControllerSelectionStrategyAutoSelectAloneAnnotations){
        if (self.annotations && self.annotations.count == 1) {
            [self performSelector:@selector(selectLastAnnotation) withObject:nil afterDelay:0.0];
        }	
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	[self didSelectAccessoryViewAtIndexPath:[self indexPathForView:view]];
}
	 
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if([view isKindOfClass:[CKAnnotationView class]]){
        CKAnnotationView* customView = (CKAnnotationView*)view;
        if(customView.calloutViewController){
            CKMapView* ckMapView = (CKMapView*)mapView;
            ckMapView.annotationToSelectAfterScrolling = customView.annotation;
            [self.mapView setCenterCoordinate:customView.annotation.coordinate animated:YES];
        }
    }

    NSIndexPath* indexPath = [self indexPathForView:view];
	[self didSelectViewAtIndexPath:indexPath];
    
    if(self.selectionBlock){
        CKMapAnnotationController* controller = (CKMapAnnotationController*)[self controllerAtIndexPath:indexPath];
        self.selectionBlock(self,controller);
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    NSIndexPath* indexPath = [self indexPathForView:view];
	
    CKMapAnnotationController* controller = (CKMapAnnotationController*)[self controllerAtIndexPath:indexPath];
	if(controller != nil){
		[controller didDeselect];
	}

    
    if(self.deselectionBlock){
        CKMapAnnotationController* controller = (CKMapAnnotationController*)[self controllerAtIndexPath:indexPath];
        self.deselectionBlock(self,controller);
    }
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
    if(!self.viewIsOnScreen){
        self.mapViewHasBeenReloaded = NO;
		return;
    }
    
	CKFeedSource* source = [self collectionDataSource];
	if ((source != nil) && source.isFetching) {
            //return NO;
	}
    
    NSArray* selected = self.mapView.selectedAnnotations;
    for(id<MKAnnotation> annotation in selected){
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
    
    self.annotationToSelect = nil;
    
    NSArray* allAnnotations = self.mapView.annotations ;
    [self.mapView  removeAnnotations:allAnnotations];
    
    /*
    while([self.mapView.annotations count] > 0){
        id <MKAnnotation> annotation = [self.mapView.annotations lastObject];
        [self.mapView removeAnnotation:annotation];
    }
     */
    
    if(self.mapView.userLocation && [self.mapView.annotations indexOfObjectIdenticalTo:self.mapView.userLocation] == NSNotFound){
        [self.mapView addAnnotation:self.mapView.userLocation];
    }
    
	NSArray* objects = [self objectsForSection:0];
	[self addAnnotations:objects];
    
    if([objects count] > 0){
        [self zoom:YES];
    }
}

- (void)onBeginUpdates{
	//To implement in inherited class
}

- (void)onEndUpdates{
}

- (void)onInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.viewIsOnScreen){
        self.mapViewHasBeenReloaded = NO;
		return;
    }
    
	[self addAnnotations:objects];
	[self zoom:YES];
}

- (void)onRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.viewIsOnScreen){
        self.mapViewHasBeenReloaded = NO;
		return;
    }
    
    for(id<MKAnnotation> annotation in objects){
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
    
	[self.mapView removeAnnotations:objects];
	[self zoom:YES];
}

- (UIView*)viewAtIndexPath:(NSIndexPath *)indexPath{
	id object = [self objectAtIndexPath:indexPath];
	return [self.mapView viewForAnnotation:object];
}

- (NSArray*)visibleIndexPaths{
	NSMutableArray* array = [NSMutableArray array];
	NSInteger count = [self numberOfObjectsForSection:0];
	for(int i=0;i<count;++i){
        [array addObject:[NSIndexPath indexPathForRow:i inSection:0]];
	}
	return array;
}

- (BOOL)reloadData{
    [super reload];
    return YES;
}

- (void)onPropertyChanged:(NSNotification*)notification{
	NSArray* objects = [self objectsForSection:0];
	CKProperty* property = [notification objectProperty];
	if([objects containsObject:property.object] == YES){
		[self reloadData];
		return;
	}
}

@end