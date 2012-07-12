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

/**
 */
@interface CKAnnotationView : MKAnnotationView

///-----------------------------------
/// @name Customizing callout content
///-----------------------------------

/**
 */
@property(nonatomic,retain)UIViewController* calloutViewController;

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