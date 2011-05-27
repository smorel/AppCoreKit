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


@interface CKMapViewController : CKItemViewContainerController <MKMapViewDelegate> {
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, assign, readwrite) NSArray *annotations;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;


- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate;

- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToRegionEnclosingAnnotations:(NSArray *)annotations animated:(BOOL)animated;

- (BOOL)reloadData;

//private
- (void)postInit;

@end