//
//  CKMapCollectionViewController.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKMapCollectionViewController.h"

#import "CKLocalization.h"
#import "UIView+AutoresizingMasks.h"
#import "UIColor+Additions.h"
#import "CKDebug.h"

#import "CKTableViewCellController.h"
#import "CKCollectionController.h"
#import "CKArrayCollection.h"

CGFloat distance(MKMapPoint p1, MKMapPoint p2){
    return sqrt(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2));
}

NSInteger compareLocations(id <MKAnnotation>obj1, id <MKAnnotation> obj2, void *context)
{
    /*
	CLLocationCoordinate2D* centerCoordinate = (CLLocationCoordinate2D*)context;
    
    MKMapPoint centerLoc = MKMapPointForCoordinate(*centerCoordinate);
    MKMapPoint obj1Loc = MKMapPointForCoordinate(obj1.coordinate);
    MKMapPoint obj2Loc = MKMapPointForCoordinate(obj2.coordinate);
    
    CGFloat dist1 = distance(obj1Loc,centerLoc);
    CGFloat dist2 = distance(obj2Loc,centerLoc);
    
    if (dist1 <dist2)
        return NSOrderedAscending;
    else if (dist1 > dist2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
    */
    
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
        if(customView.calloutViewControllerCreationBlock){
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



@interface CKCollectionViewController()
@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;

- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

@end

//
@interface CKMapCollectionViewController()
- (void)zoom:(BOOL)animated;
@property (nonatomic, retain) id nearestAnnotation;
@property (nonatomic, assign) BOOL mapViewHasBeenReloaded;
@end


@implementation CKMapCollectionViewController{
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
	
	CKMapCollectionViewControllerZoomStrategy _zoomStrategy;
    BOOL _includeUserLocationWhenZooming;
	CGFloat _smartZoomDefaultRadius;
	NSInteger _smartZoomMinimumNumberOfAnnotations;
	
	id _annotationToSelect;
	id _nearestAnnotation;
}

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

	_zoomStrategy = CKMapCollectionViewControllerZoomStrategyEnclosing;
    _selectionStrategy = CKMapCollectionViewControllerSelectionStrategyAutoSelectAloneAnnotations;
	_smartZoomMinimumNumberOfAnnotations = 3;
	_smartZoomDefaultRadius = 1000;
    _includeUserLocationWhenZooming = YES;
    _mapViewHasBeenReloaded = NO;
    
    if(!self.controllerFactory){
        CKCollectionCellControllerFactory* factory = [CKCollectionCellControllerFactory factory];
        [factory addItemForObjectOfClass:[NSObject class] withControllerCreationBlock:^CKCollectionCellController *(id object, NSIndexPath *indexPath) {
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
    
    /*
    if([self.annotations count] > 0 || (self.centerCoordinate.latitude != 0 && self.centerCoordinate.longitude != 0)){
        self.mapView.centerCoordinate = self.centerCoordinate;
        [self addAnnotations:self.annotations];
    }else{
        [self.mapView setVisibleMapRect:MKMapRectWorld];
    }
     */
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
	
    
    if(!self.mapViewHasBeenReloaded){
        self.mapViewHasBeenReloaded = YES;
        [self reload];
    }
    
    [self updateVisibleViewsRotation];
	
	for(int i =0; i< [self numberOfSections];++i){
		[self fetchMoreIfNeededFromIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
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
    
    @try {
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:animated];
    }
    @catch (NSException *exception) {
    }
}

- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius animated:(BOOL)animated {
	self.centerCoordinate = coordinate;
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.centerCoordinate, radius, radius);
    @try {
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:animated];
    }
    @catch (NSException *exception) {
    }
}

- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
	[self zoomToCenterCoordinate:coordinate radius:500.0f animated:animated];
}

- (void)zoomToRegionEnclosingAnnotations:(NSArray *)theAnnotations animated:(BOOL)animated {
	if (theAnnotations.count == 0) return;
	
	CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in theAnnotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    /*
    MKMapPoint topLeftPoint = MKMapPointForCoordinate(topLeftCoord);
    MKMapPoint bottomRightPoint = MKMapPointForCoordinate(bottomRightCoord);
    
	MKMapPoint centerPoint = MKMapPointMake(topLeftPoint.x + ((bottomRightPoint.x - topLeftPoint.x) / 2), topLeftPoint.y + ((bottomRightPoint.y - topLeftPoint.y) / 2));
    CGFloat width = (bottomRightPoint.x - topLeftPoint.x);
    CGFloat height = (bottomRightPoint.y - topLeftPoint.y);
    
    
    CGFloat mapMetersPerPoints = MKMetersPerMapPointAtLatitude((bottomRightCoord.latitude - topLeftCoord.latitude)/2.0f);
    CGFloat offset = 500 / mapMetersPerPoints;
    
    MKMapRect zoomRect = MKMapRectMake(centerPoint.x, centerPoint.y, width + offset, height + offset);
    [self.mapView setVisibleMapRect:zoomRect animated:animated];
*/
    
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides

    @try {
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:animated];
    }
    @catch (NSException *exception) {
    }
}


- (void)animatedZoomToRegionEnclosingAnnotations:(NSArray *)annotations {
    [self zoomToRegionEnclosingAnnotations:annotations animated:YES];
}

- (void)notAnimatedZoomToRegionEnclosingAnnotations:(NSArray *)annotations {
    [self zoomToRegionEnclosingAnnotations:annotations animated:NO];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if(self.zoomStrategy == CKMapCollectionViewControllerZoomStrategySmart){
        if(_centerCoordinate.latitude == 0 && _centerCoordinate.longitude == 0){
            [self smartZoomWithAnnotations:self.annotations animated:YES];
        }
  }
}

- (void)smartZoomWithAnnotations:(NSArray *)annotations animated:(BOOL)animated{
    
    if(_centerCoordinate.latitude == 0 && _centerCoordinate.longitude == 0){
        _centerCoordinate = self.mapView.userLocation.coordinate;
    }
  
  if(_centerCoordinate.latitude == 0 && _centerCoordinate.longitude == 0){
    return;
    //Waiting for user location to get set
  }
    
    
  self.nearestAnnotation = nil;
  BOOL foundNearest = NO;
	NSArray* orderedByDistance = [annotations sortedArrayUsingFunction:&compareLocations context:&_centerCoordinate];
	NSMutableArray* theAnnotations = [NSMutableArray array];
	for (NSObject<MKAnnotation> *annotation in orderedByDistance) {
		[theAnnotations addObject:annotation];
		if(annotation.coordinate.latitude != _centerCoordinate.latitude
		   && annotation.coordinate.longitude != _centerCoordinate.longitude
		   && !foundNearest/*_nearestAnnotation == nil*/){
          
          //PATCH :BAD !!!!
          foundNearest = YES;
          
          //Delay because when the controller appears, goToDefaultLocation on map is called
          //during this zoom, we receive didUpdateUserLocation that sets self.nearestAnnotation
          //and as we set a new zoom, regionDidChange is called and self.nearestAnnotation is handled
          //as a result of the previous zoom not the one triggered by smart zoom.
          [self performSelector:@selector(setNearestAnnotation:) withObject:annotation afterDelay:0.4];
		
          //self.nearestAnnotation = annotation;
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
        /*
        CGFloat mapMetersPerPoints = MKMetersPerMapPointAtLatitude(_centerCoordinate.latitude);
        CGFloat rectSize = _smartZoomDefaultRadius / mapMetersPerPoints;
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(_centerCoordinate);
        MKMapRect zoomRect = MKMapRectMake(annotationPoint.x - (rectSize / 2), annotationPoint.y - (rectSize / 2), rectSize, rectSize);
        [self.mapView setVisibleMapRect:zoomRect animated:YES];
        */
        
		MKCoordinateRegion region;
		region.center.latitude = _centerCoordinate.latitude;
		region.center.longitude = _centerCoordinate.longitude;
		region.span.latitudeDelta = _smartZoomDefaultRadius / 111319.5;
		region.span.longitudeDelta = 0.009;
		
        @try {
            region = [self.mapView regionThatFits:region];
            [self.mapView setRegion:region animated:animated];
        }
        @catch (NSException *exception) {
        }
	}
}


- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapCollectionViewControllerZoomStrategy)strategy animated:(BOOL)animated{
    NSMutableArray* theAnnotations = [NSMutableArray arrayWithArray:annotations];
    if(!self.includeUserLocationWhenZooming && self.mapView.userLocation){
        NSInteger index = [theAnnotations indexOfObjectIdenticalTo:self.mapView.userLocation];
        while(index != NSNotFound){
            [theAnnotations removeObjectAtIndex:index];
            index = [theAnnotations indexOfObjectIdenticalTo:self.mapView.userLocation];
        }
    }
    
	switch(strategy){
		case CKMapCollectionViewControllerZoomStrategySmart:{
			[self smartZoomWithAnnotations:theAnnotations animated:animated];
			break;
		}
		case CKMapCollectionViewControllerZoomStrategyEnclosing:{
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
		[self.mapView selectAnnotation:self.annotationToSelect animated:animated];
	}
	else if(self.nearestAnnotation != nil){
		[self.mapView selectAnnotation:self.nearestAnnotation animated:animated];
        self.nearestAnnotation = nil;//only the first time !
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
	
	CKAssert([view isKindOfClass:[MKAnnotationView class]],@"invalid type for view");
	return (MKAnnotationView*)view;
}

- (void)selectLastAnnotation {
    if([self.annotations count] > 0){
        [self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	// If displaying only one entry, select it
    if(_selectionStrategy == CKMapCollectionViewControllerSelectionStrategyAutoSelectAloneAnnotations){
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
        if(customView.calloutViewControllerCreationBlock){
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

- (void)didReload{
    if(!self.isViewDisplayed){
        self.mapViewHasBeenReloaded = NO;
		return;
    }
    
    BOOL animated = (self.state == CKViewControllerStateDidAppear);
    
    NSArray* selected = self.mapView.selectedAnnotations;
    for(id<MKAnnotation> annotation in selected){
        [self.mapView deselectAnnotation:annotation animated:animated];
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
        [self zoom:animated];
    }
}

- (void)didBeginUpdates{
	//To implement in inherited class
}

- (void)didEndUpdates{
}

- (void)didInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.isViewDisplayed){
        self.mapViewHasBeenReloaded = NO;
		return;
    }
    
	[self addAnnotations:objects];
	[self zoom:YES];
}

- (void)didRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
    if(!self.isViewDisplayed){
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

@end