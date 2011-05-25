//
//  CKMapViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-08-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CKUIViewController.h"
#import "CKObjectController.h"
#import "CKObjectViewControllerFactory.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKDocumentCollection.h"

#define MAP_ANNOTATION_LEFT_BUTTON	1
#define MAP_ANNOTATION_RIGHT_BUTTON	2


@interface CKMapViewController : CKUIViewController <CKObjectControllerDelegate,MKMapViewDelegate> {
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
	
	id _objectController;
	CKObjectViewControllerFactory* _controllerFactory;
	NSMutableDictionary* _params;
	NSMutableDictionary* _cellsToControllers;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, assign, readwrite) NSArray *annotations;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKObjectViewControllerFactory* controllerFactory;

- (id)initWithCollection:(CKDocumentCollection*)collection mappings:(NSArray*)mappings;
- (id)initWithObjectController:(id)controller withControllerFactory:(CKObjectViewControllerFactory*)factory;
- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate;

- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToRegionEnclosingAnnotations:(NSArray *)annotations animated:(BOOL)animated;

- (void)reloadData;

//private
- (void)postInit;

@end