//
//  CKMapViewController.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKMapViewController.h"

#import "CKLocalization.h"
#import "UIView+AutoresizingMasks.h"
#import "UIColor+Additions.h"
#import "CKDebug.h"
#import "NSObject+Invocation.h"

#import "CKCollectionController.h"
#import "CKArrayCollection.h"

#import "CKResourceManager.h"
#import "CKVersion.h"
#import "UIView+CKLayout.h"

#import <objc/runtime.h>


CGFloat distance(MKMapPoint p1, MKMapPoint p2){
    return (CGFloat)(sqrt(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2)));
}

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
@end

@implementation CKMapView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //Because on ios 6 and earlier MKMapView layoutSubViews seems not to call the super implementation
    if([CKOSVersion() floatValue] < 7){
        if(self.layoutBoxes && !self.containerLayoutBox){
            [self performLayoutWithFrame:self.bounds];
        }
    }
}

@end


//
@interface CKMapViewController()
- (void)zoom:(BOOL)animated;
@property (nonatomic, retain) id nearestAnnotation;
@property (nonatomic,retain,readwrite) CKSectionContainer* sectionContainer;
@end


@implementation CKMapViewController{
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
	
	CKMapViewControllerZoomStrategy _zoomStrategy;
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

- (void)postInit {
	[super postInit];
    
    self.sectionContainer = [[[CKSectionContainer alloc]initWithDelegate:self]autorelease];

	_zoomStrategy = CKMapViewControllerZoomStrategyEnclosing;
    _selectionStrategy = CKMapViewControllerSelectionStrategyAutoSelectAloneAnnotations;
	_smartZoomMinimumNumberOfAnnotations = 3;
	_smartZoomDefaultRadius = 1000;
    _includeUserLocationWhenZooming = YES;
}

- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate {
	self = [super init];
    if (self) {
        [self setAnnotations:annotations];
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
    [_sectionContainer release];
    _sectionContainer = nil;
    [super dealloc];
}

#pragma mark View Management

- (void)addAnnotations:(NSArray*)annotations{
	[self.mapView addAnnotations:annotations];
}

- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithRGBValue:0xc1bfbb];	
	
	if (self.mapView == nil) {
		self.mapView = [[[CKMapView alloc] initWithFrame:self.view.bounds] autorelease];
		self.mapView.autoresizingMask = UIViewAutoresizingFlexibleSize;
		[self.view addSubview:self.mapView];		
	}

	self.mapView.delegate = self;

    [super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.mapView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	self.mapView.delegate = self;
	self.mapView.frame = self.view.bounds;
    
    for(CKAbstractSection* section in self.sectionContainer.sections){
        [section fetchNextPageFromIndex:0];
    }
}


-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//self.mapView.showsUserLocation = NO;
	self.mapView.delegate = nil;
}

#pragma mark Annotations

- (void)setAnnotations:(NSArray *)theAnnotations {
    [self removeAllSectionsAnimated:NO];
    
    CKReusableViewControllerFactory* factory = [CKMapViewController defaultFactory];
    CKCollectionSection* section = [CKCollectionSection sectionWithCollection:[CKArrayCollection collectionWithObjectsFromArray:theAnnotations] factory:factory];
    [self addSection:section animated:NO];
}

- (NSArray*)annotations{
    CKAbstractSection* firstSection = [self.sectionContainer sectionAtIndex:0];
    return [firstSection isKindOfClass:[CKCollectionSection class]] ? [[(CKCollectionSection*)firstSection collection]allObjects] : nil;
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
    if(self.zoomStrategy == CKMapViewControllerZoomStrategySmart){
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
          //[self performSelector:@selector(setNearestAnnotation:) withObject:annotation afterDelay:0.05];
		
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
		
        @try {
            region = [self.mapView regionThatFits:region];
            [self.mapView setRegion:region animated:animated];
        }
        @catch (NSException *exception) {
        }
	}
}


- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapViewControllerZoomStrategy)strategy animated:(BOOL)animated{
    NSMutableArray* theAnnotations = [NSMutableArray arrayWithArray:annotations];
    if(!self.includeUserLocationWhenZooming && self.mapView.userLocation){
        NSInteger index = [theAnnotations indexOfObjectIdenticalTo:self.mapView.userLocation];
        while(index != NSNotFound){
            [theAnnotations removeObjectAtIndex:index];
            index = [theAnnotations indexOfObjectIdenticalTo:self.mapView.userLocation];
        }
    }
    
	switch(strategy){
		case CKMapViewControllerZoomStrategySmart:{
			[self smartZoomWithAnnotations:theAnnotations animated:animated];
			break;
		}
		case CKMapViewControllerZoomStrategyEnclosing:{
			[self zoomToRegionEnclosingAnnotations:theAnnotations animated:animated];
			break;
		}
	}
}

- (void)zoom:(BOOL)animated{
	[self zoomOnAnnotations:self.mapView.annotations withStrategy:self.zoomStrategy animated:animated];
}

#pragma mark MKMapView Delegate

- (void)selectNearestAnnotation:(BOOL)animated{
	if(self.annotationToSelect != nil && [self.mapView.annotations containsObject:_annotationToSelect]){
		[self.mapView selectAnnotation:self.annotationToSelect animated:animated];
	}
	else if(self.nearestAnnotation != nil){
		[self.mapView selectAnnotation:self.nearestAnnotation animated:animated];
        self.nearestAnnotation = nil;//only the first time !
	}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CKMapView* ckMapView = (CKMapView*)mapView;

    //Force animated here for map to scroll when selecting to avoid the callout to be cropped.
    [self selectNearestAnnotation:YES];
    
    if(_didScrollBlock){
        _didScrollBlock(self,animated);
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
}

- (void)selectLastAnnotation {
    if([self.annotations count] > 0){
        [self.mapView selectAnnotation:[self.annotations lastObject] animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	// If displaying only one entry, select it
    if(_selectionStrategy == CKMapViewControllerSelectionStrategyAutoSelectAloneAnnotations){
        if (self.annotations && self.annotations.count == 1) {
            [self performSelector:@selector(selectLastAnnotation) withObject:nil afterDelay:0.0];
        }	
    }
}


#pragma Managing IndexPaths

- (NSIndexPath*)indexPathForAnnotation:(id<MKAnnotation>)annotation{
    CKReusableViewController* controller = [self controllerForAnnotation:annotation];
    return controller.indexPath;
}

- (CKReusableViewController*)controllerForAnnotation:(id<MKAnnotation>)annotation{
    for(CKAbstractSection* section in self.sectionContainer.sections){
        for(CKReusableViewController* controller in section.controllers){
            if(annotation == controller.mapAnnotation){
                return controller;
            }
        }
    }
    return nil;
}

#pragma Managing Appearance

+ (CKReusableViewControllerFactory*)defaultFactory{
    CKReusableViewControllerFactory* factory = [CKReusableViewControllerFactory factory];
    [factory registerFactoryForObjectOfClass:[NSObject class] factory:^CKReusableViewController *(id object, NSIndexPath *indexPath) {
        CKReusableViewController* controller = [CKReusableViewController controller];
        if([object conformsToProtocol:@protocol(MKAnnotation)]){
            [controller setMapAnnotation:(id<MKAnnotation>)object];
        }
        return controller;
    }];
    return factory;
}

- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier forIndexPath:(NSIndexPath*)indexPath{
    return [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if (annotation == mapView.userLocation)
        return nil;
    
    CKReusableViewController* controller = [self controllerForAnnotation:annotation];
    NSString* reuseIdentifier = [controller reuseIdentifier];
    
    MKAnnotationView* view = (MKAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if(!view){
        view = [[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]autorelease];
    }
    
    return (MKAnnotationView*)[self.sectionContainer viewForControllerAtIndexPath:controller.indexPath reusingView:view];
}

#pragma Managing Selection

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    CKReusableViewController* controller = [self controllerForAnnotation:view.annotation];
    [controller didSelectAccessory];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    CKReusableViewController* controller = [self controllerForAnnotation:view.annotation];
    
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected addObject:controller.indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    
    [controller didSelect];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    CKReusableViewController* controller = [self controllerForAnnotation:view.annotation];
    
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected removeObject:controller.indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    
    [controller didDeselect];
}


#pragma Managing Batch Updates

- (void)performBatchUpdates:(void (^)(void))updates
                 completion:(void (^)(BOOL finished))completion{
    
    if(updates){
        updates();
    }
    
    if(completion){
        completion(YES);
    }
}


#pragma mark CKSectionedViewController protocol

- (NSArray*)annotationsForControllers:(NSArray*)controllers{
    NSMutableArray* annotations = [NSMutableArray array];
    for(CKReusableViewController* controller in controllers){
        [annotations addObject:controller.mapAnnotation];
    }
    return annotations;
}

- (NSArray*)annotationsForSections:(NSArray*)sections{
    NSMutableArray* annotations = [NSMutableArray array];
    for(CKAbstractSection* section in sections){
        [annotations addObject:[self annotationsForControllers:section.controllers]];
    }
    return annotations;
}

- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.mapView addAnnotations:[self annotationsForSections:sections]];
    } completion:^(BOOL finished) {
        [self zoom:animated];
    }];
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.mapView removeAnnotations:[self annotationsForSections:sections]];
    } completion:nil];
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.mapView addAnnotations:[self annotationsForControllers:controllers]];
    } completion:^(BOOL finished) {
        [self zoom:animated];
    }];
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.mapView removeAnnotations:[self annotationsForControllers:controllers]];
    } completion:nil ];
}

- (UIView*)contentView{
    return self.mapView;
}

- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated{
    CKReusableViewController* controller = [self controllerAtIndexPath:indexpath];
    [self.mapView setCenterCoordinate:controller.mapAnnotation.coordinate animated:animated];
}


/* Forwarding calls to section container
 */

- (NSInteger)indexOfSection:(CKAbstractSection*)section{
    return [self.sectionContainer indexOfSection:section];
}

- (NSIndexSet*)indexesOfSections:(NSArray*)sections{
    return [self.sectionContainer indexesOfSections:sections];
}

- (id)sectionAtIndex:(NSInteger)index{
    return [self.sectionContainer sectionAtIndex:index];
}

- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes{
    return [self.sectionContainer sectionsAtIndexes:indexes];
}

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer addSection:section animated:animated];
}

- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer insertSection:section atIndex:index animated:animated];
}

- (void)addSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer addSections:sections animated:animated];
}

- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer insertSections:sections atIndexes:indexes animated:animated];
}

- (void)removeAllSectionsAnimated:(BOOL)animated{
    [self.sectionContainer removeAllSectionsAnimated:animated];
}

- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer removeSection:section animated:animated];
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer removeSectionAtIndex:index animated:animated];
}

- (void)removeSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer removeSections:sections animated:animated];
}

- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer removeSectionsAtIndexes:indexes animated:animated];
}

- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath{
    return [self.sectionContainer controllerAtIndexPath:indexPath];
}

- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths{
    return [self.sectionContainer controllersAtIndexPaths:indexPaths];
}

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller{
    return [self.sectionContainer indexPathForController:controller];
}

- (NSArray*)indexPathsForControllers:(NSArray*)controllers{
    return [self.sectionContainer indexPathsForControllers:controllers];
}

- (void)setSelectedIndexPaths:(NSArray*)selectedIndexPaths{
    self.sectionContainer.selectedIndexPaths = selectedIndexPaths;
}

- (NSArray*)selectedIndexPaths{
    return self.sectionContainer.selectedIndexPaths;
}

@end















@interface CKMapAnnotation : NSObject<MKAnnotation>
@end

@implementation CKMapAnnotation

- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(0, 0);
}

@end



static char CKReusableViewControllerMapAnnotationKey;


/**
 */
@implementation CKReusableViewController(CKMapViewController)

@dynamic mapAnnotationView,mapView,mapAnnotation;

- (MKAnnotationView*)mapAnnotationView{
    if([self.contentViewCell isKindOfClass:[MKAnnotationView class]])
        return (MKAnnotationView*)self.contentViewCell;
    return nil;
}

- (MKMapView*)mapView{
    if([self.contentView isKindOfClass:[MKMapView class]])
        return (MKMapView*)self.contentView;
    return nil;
}

- (void)setMapAnnotation:(id<MKAnnotation>)mapAnnotation{
    objc_setAssociatedObject(self, &CKReusableViewControllerMapAnnotationKey, mapAnnotation, OBJC_ASSOCIATION_RETAIN);
}

- (id<MKAnnotation>) mapAnnotation{
    id<MKAnnotation> annotation = objc_getAssociatedObject(self, &CKReusableViewControllerMapAnnotationKey);
    if(!annotation){
        annotation = [[[CKMapAnnotation alloc]init]autorelease];
        [self setMapAnnotation:annotation];
    }
    return annotation;
}

@end

