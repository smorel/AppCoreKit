//
//  CKMapViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-08-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CKItemViewContainerController.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKDocumentCollection.h"

#import "CKMapAnnotationController.h"

#define MAP_ANNOTATION_LEFT_BUTTON	1
#define MAP_ANNOTATION_RIGHT_BUTTON	2


typedef enum CKMapViewControllerZoomStrategy{
	CKMapViewControllerZoomStrategyEnclosing,
	CKMapViewControllerZoomStrategySmart
}CKMapViewControllerZoomStrategy;

@interface CKMapViewController : CKItemViewContainerController <MKMapViewDelegate> {
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
	
	CKMapViewControllerZoomStrategy _zoomStrategy;
	CGFloat _smartZoomDefaultRadius;
	NSInteger _smartZoomMinimumNumberOfAnnotations;
	
	id _annotationToSelect;
	id _nearestAnnotation;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, assign, readwrite) NSArray *annotations;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;

@property (nonatomic, assign) CKMapViewControllerZoomStrategy zoomStrategy;
@property (nonatomic, assign) CGFloat smartZoomDefaultRadius;
@property (nonatomic, assign) NSInteger smartZoomMinimumNumberOfAnnotations;
@property (nonatomic, retain) id annotationToSelect;


- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate;

- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToRegionEnclosingAnnotations:(NSArray *)annotations animated:(BOOL)animated;
- (void)smartZoomWithAnnotations:(NSArray *)annotations animated:(BOOL)animated;
- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapViewControllerZoomStrategy)strategy animated:(BOOL)animated;

- (BOOL)reloadData;
- (BOOL)reloadData:(BOOL)animated;

//private
- (void)postInit;

@end