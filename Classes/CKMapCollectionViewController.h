//
//  CKMapCollectionViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-08-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CKCollectionViewController.h"
#import "CKObjectController.h"
#import "CKCollectionCellControllerFactory.h"
#import "CKCollection.h"

#import "CKMapAnnotationController.h"

#define MAP_ANNOTATION_LEFT_BUTTON	1
#define MAP_ANNOTATION_RIGHT_BUTTON	2


/** TODO
 */
typedef enum CKMapCollectionViewControllerZoomStrategy{
    CKMapCollectionViewControllerZoomStrategyManual,
	CKMapCollectionViewControllerZoomStrategyEnclosing,
	CKMapCollectionViewControllerZoomStrategySmart
}CKMapCollectionViewControllerZoomStrategy;


typedef enum CKMapCollectionViewControllerSelectionStrategy{
    CKMapCollectionViewControllerSelectionStrategyManual,
    CKMapCollectionViewControllerSelectionStrategyAutoSelectAloneAnnotations
}CKMapCollectionViewControllerSelectionStrategy;

@class CKMapCollectionViewController;
typedef void(^CKMapCollectionViewControllerSelectionBlock)(CKMapCollectionViewController* controller, CKMapAnnotationController* annotationController);
typedef void(^CKMapCollectionViewControllerScrollBlock)(CKMapCollectionViewController* controller,BOOL animated);


/** TODO
 */
@interface CKMapCollectionViewController : CKCollectionViewController <MKMapViewDelegate> {
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
	
	CKMapCollectionViewControllerZoomStrategy _zoomStrategy;
    BOOL _includeUserLocationWhenZooming;
	CGFloat _smartZoomDefaultRadius;
	NSInteger _smartZoomMinimumNumberOfAnnotations;
	
	id _annotationToSelect;
	id _nearestAnnotation;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, assign, readwrite) NSArray *annotations;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;

@property (nonatomic, assign) CKMapCollectionViewControllerZoomStrategy zoomStrategy;
@property (nonatomic, assign) CKMapCollectionViewControllerSelectionStrategy selectionStrategy;
@property (nonatomic, assign) CGFloat smartZoomDefaultRadius;
@property (nonatomic, assign) NSInteger smartZoomMinimumNumberOfAnnotations;
@property (nonatomic, assign) BOOL includeUserLocationWhenZooming;
@property (nonatomic, retain) id annotationToSelect;

@property (nonatomic, copy) CKMapCollectionViewControllerSelectionBlock selectionBlock;
@property (nonatomic, copy) CKMapCollectionViewControllerSelectionBlock deselectionBlock;
@property (nonatomic, copy) CKMapCollectionViewControllerScrollBlock didScrollBlock;


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
- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapCollectionViewControllerZoomStrategy)strategy animated:(BOOL)animated;

- (BOOL)reloadData;

@end