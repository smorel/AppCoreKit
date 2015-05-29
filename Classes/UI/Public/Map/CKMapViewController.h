//
//  CKMapViewController.h
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "CKSectionContainer.h"

/**
 */
@interface CKReusableViewController(CKMapViewController)

/**
 */
@property(nonatomic,readonly) MKAnnotationView* mapAnnotationView;

/**
 */
@property(nonatomic,readonly) MKMapView* mapView;

/** Default value is an empty object implementing MKAnnotation located at 0,0.
 */
@property(nonatomic,readwrite) id<MKAnnotation> mapAnnotation;

@end





/**
 */
typedef NS_ENUM(NSInteger, CKMapViewControllerZoomStrategy){
    CKMapViewControllerZoomStrategyManual,
	CKMapViewControllerZoomStrategyEnclosing,
	CKMapViewControllerZoomStrategySmart
};

/**
 */
typedef NS_ENUM(NSInteger, CKMapViewControllerSelectionStrategy){
    CKMapViewControllerSelectionStrategyManual,
    CKMapViewControllerSelectionStrategyAutoSelectAloneAnnotations
};


@class CKMapViewController;
typedef void(^CKMapViewControllerSelectionBlock)(CKMapViewController* controller, CKReusableViewController* annotationController);
typedef void(^CKMapViewControllerScrollBlock)(CKMapViewController* controller,BOOL animated);


/**
 */
@interface CKMapViewController : UIViewController <CKSectionContainerDelegate,MKMapViewDelegate>

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
@property (nonatomic, assign) CKMapViewControllerSelectionStrategy selectionStrategy;

/**
 */
@property (nonatomic, copy) CKMapViewControllerSelectionBlock selectionBlock;

/**
 */
@property (nonatomic, copy) CKMapViewControllerSelectionBlock deselectionBlock;


///-----------------------------------
/// @name Panning
///-----------------------------------

/**
 */
- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

/**
 */
@property (nonatomic, copy) CKMapViewControllerScrollBlock didScrollBlock;

/**
 */
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;



///-----------------------------------
/// @name Zooming
///-----------------------------------

/**
 */
@property (nonatomic, assign) CKMapViewControllerZoomStrategy zoomStrategy;

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
- (void)zoomOnAnnotations:(NSArray *)annotations withStrategy:(CKMapViewControllerZoomStrategy)strategy animated:(BOOL)animated;

/**
 */
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate radius:(CGFloat)radius animated:(BOOL)animated;


+ (CKReusableViewControllerFactory*)defaultFactory;

- (NSIndexPath*)indexPathForAnnotation:(id<MKAnnotation>)annotation;
- (CKReusableViewController*)controllerForAnnotation:(id<MKAnnotation>)annotation;

- (NSInteger)indexOfSection:(CKAbstractSection*)section;
- (NSIndexSet*)indexesOfSections:(NSArray*)sections;

- (id)sectionAtIndex:(NSInteger)index;
- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes;

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated;
- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)addSections:(NSArray*)sections animated:(BOOL)animated;
- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (void)removeAllSectionsAnimated:(BOOL)animated;
- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated;
- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeSections:(NSArray*)sections animated:(BOOL)animated;
- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated;

- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath;
- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths;

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller;
- (NSArray*)indexPathsForControllers:(NSArray*)controllers;

@end