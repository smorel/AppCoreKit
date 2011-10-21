//
//  CKMapViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-08-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
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


/** TODO
 */
typedef enum CKMapViewControllerZoomStrategy{
	CKMapViewControllerZoomStrategyEnclosing,
	CKMapViewControllerZoomStrategySmart
}CKMapViewControllerZoomStrategy;


/** TODO
 */
@interface CKMapViewController : CKItemViewContainerController <MKMapViewDelegate> {
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
	
	CKMapViewControllerZoomStrategy _zoomStrategy;
    BOOL _includeUserLocationWhenZooming;
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
@property (nonatomic, assign) BOOL includeUserLocationWhenZooming;
@property (nonatomic, retain) id annotationToSelect;


- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate;

- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius animated:(BOOL)animated;

/** 
 Zooms to a default radius of 500m
 @param coordinate The center coordinate
 @param animated Animates the zoom
 @see zoomToCenterCoordinate:radius:animated:
 */
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToRegionEnclosingAnnotations:(NSArray *)annotations animated:(BOOL)animated;
- (void)smartZoomWithAnnotations:(NSArray *)annotations animated:(BOOL)animated;
- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapViewControllerZoomStrategy)strategy animated:(BOOL)animated;

- (BOOL)reloadData;
- (BOOL)reloadData:(BOOL)animated;

@end