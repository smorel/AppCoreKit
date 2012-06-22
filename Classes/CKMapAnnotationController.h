//
//  CKMapAnnotationController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CKCollectionCellController.h"
#import "CKViewController.h"

/** TODO
 */
typedef enum CKMapAnnotationStyle{
	CKMapAnnotationCustom,
	CKMapAnnotationPin
}CKMapAnnotationStyle;

@class CKMapAnnotationController;

/** TODO
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


/** TODO
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


#import "CKMapAnnotationController+CKBlockBasedInterface.h"