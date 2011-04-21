//
//  CKMapViewController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-08-20.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define MAP_ANNOTATION_LEFT_BUTTON	1
#define MAP_ANNOTATION_RIGHT_BUTTON	2


@interface CKMapViewController : UIViewController <MKMapViewDelegate> {
	NSArray *_annotations;
	CLLocationCoordinate2D _centerCoordinate;
	MKMapView *_mapView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSArray *annotations;
@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinate;

- (id)initWithAnnotations:(NSArray *)annotations atCoordinate:(CLLocationCoordinate2D)centerCoordinate;

- (void)panToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;
- (void)zoomToRegionEnclosingAnnotations:(NSArray *)annotations animated:(BOOL)animated;

@end