//
//  CKMapCollectionViewController.h
//  AppCoreKit
//
//  Created by Olivier Collet.
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

/**
 */
typedef enum CKMapCollectionViewControllerZoomStrategy{
    CKMapCollectionViewControllerZoomStrategyManual,
	CKMapCollectionViewControllerZoomStrategyEnclosing,
	CKMapCollectionViewControllerZoomStrategySmart
}CKMapCollectionViewControllerZoomStrategy;

/**
 */
typedef enum CKMapCollectionViewControllerSelectionStrategy{
    CKMapCollectionViewControllerSelectionStrategyManual,
    CKMapCollectionViewControllerSelectionStrategyAutoSelectAloneAnnotations
}CKMapCollectionViewControllerSelectionStrategy;


@class CKMapCollectionViewController;
typedef void(^CKMapCollectionViewControllerSelectionBlock)(CKMapCollectionViewController* controller, CKMapAnnotationController* annotationController);
typedef void(^CKMapCollectionViewControllerScrollBlock)(CKMapCollectionViewController* controller,BOOL animated);


/**
 */
@interface CKMapCollectionViewController : CKCollectionViewController <MKMapViewDelegate> 

///-----------------------------------
/// @name Initializing a Map View Controller
///-----------------------------------

/**
 */
- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate;

///-----------------------------------
/// @name Getting the Map View
///-----------------------------------

/**
 */
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

///-----------------------------------
/// @name Accessing the annotations
///-----------------------------------

/**
 */
@property (nonatomic, assign, readwrite) NSArray *annotations;


///-----------------------------------
/// @name Customizing the annotation selection behaviour
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKMapCollectionViewControllerSelectionStrategy selectionStrategy;

/**
 */
@property (nonatomic, copy) CKMapCollectionViewControllerSelectionBlock selectionBlock;

/**
 */
@property (nonatomic, copy) CKMapCollectionViewControllerSelectionBlock deselectionBlock;


///-----------------------------------
/// @name Panning
///-----------------------------------

/**
 */
- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

/**
 */
@property (nonatomic, copy) CKMapCollectionViewControllerScrollBlock didScrollBlock;

/**
 */
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;



///-----------------------------------
/// @name Zooming
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKMapCollectionViewControllerZoomStrategy zoomStrategy;

/**
 */
@property (nonatomic, assign) CGFloat smartZoomDefaultRadius;

/**
 */
@property (nonatomic, assign) NSInteger smartZoomMinimumNumberOfAnnotations;

/**
 */
@property (nonatomic, assign) BOOL includeUserLocationWhenZooming;

/**
 */
@property (nonatomic, retain) id annotationToSelect;

/** 
 Zooms to a default radius of 500m
 @param coordinate The center coordinate
 @param animated Animates the zoom
 @see zoomToCenterCoordinate:radius:animated:
 */
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

/**
 */
- (void)zoomToRegionEnclosingAnnotations:(NSArray *)annotations animated:(BOOL)animated;

/**
 */
- (void)smartZoomWithAnnotations:(NSArray *)annotations animated:(BOOL)animated;

/**
 */
- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapCollectionViewControllerZoomStrategy)strategy animated:(BOOL)animated;

/**
 */
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius animated:(BOOL)animated;


@end