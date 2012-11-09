//
//  CKMapAnnotationController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CKCollectionCellController.h"
#import "CKViewController.h"

/**
 */
typedef enum CKMapAnnotationStyle{
	CKMapAnnotationCustom,
	CKMapAnnotationPin
}CKMapAnnotationStyle;

@class CKMapAnnotationController;
@class CKAnnotationView;

typedef UIViewController*(^CKAnnotationCalloutViewControllerCreationBlock)(CKMapAnnotationController* annotationController, CKAnnotationView* annotationView);


/**
 */
@interface CKAnnotationView : MKAnnotationView

///-----------------------------------
/// @name Customizing callout content
///-----------------------------------

/**
 */
@property(nonatomic,copy) CKAnnotationCalloutViewControllerCreationBlock calloutViewControllerCreationBlock;

///-----------------------------------
/// @name Accessing the parent controllers and views
///-----------------------------------

/**
 */
@property(nonatomic,assign)CKMapAnnotationController* annotationController;

/**
 */
- (MKMapView*)mapView;

@end


/**
 */
@interface CKMapAnnotationController : CKCollectionCellController

///-----------------------------------
/// @name Creating Annotation Controller Objects
///-----------------------------------

/**
 */
+ (CKMapAnnotationController*)annotationController;

/**
 */
+ (CKMapAnnotationController*)annotationControllerWithName:(NSString*)name;

///-----------------------------------
/// @name Customizing the Appearance
///-----------------------------------

/**
 */
@property (nonatomic,assign) CKMapAnnotationStyle style;

/** When inheriting CKMapAnnotationController you can override this method to return your own custom intitialized MKAnnotationView.
 */
- (MKAnnotationView*)loadAnnotationView;

/** When inheriting CKMapAnnotationController you can override this method to return your own custom intitialized MKAnnotationView using the specified style.
 */
- (MKAnnotationView*)viewWithStyle:(CKMapAnnotationStyle)style;

///-----------------------------------
/// @name Customizing the Selection behaviour
///-----------------------------------

/**
 */
@property (nonatomic, retain) CKCallback* deselectionCallback;
/**
 */
- (void)didDeselect;



@end


#import "CKMapAnnotationController+BlockBasedInterface.h"