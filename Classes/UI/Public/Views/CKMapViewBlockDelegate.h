//
//  CKMapViewBlockDelegate.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/4/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import <MapKit/MapKit.h>

/**
 */
@interface CKMapViewBlockDelegate : NSObject

/** The map view will automatically retain the newly created instance until it gets deallocated
 */
- (id)initWithMapView:(MKMapView*)mapView;

@property(nonatomic,copy) void(^regionWillChangeAnimated)(MKMapView* mapView,BOOL animated);
@property(nonatomic,copy) void(^regionDidChangeAnimated)(MKMapView* mapView,BOOL animated);
@property(nonatomic,copy) void(^willStartLoadingMap)(MKMapView* mapView);
@property(nonatomic,copy) void(^didFinishLoadingMap)(MKMapView* mapView);
@property(nonatomic,copy) void(^didFailLoadingMap)(MKMapView* mapView, NSError* error);
@property(nonatomic,copy) void(^willStartRenderingMap)(MKMapView* mapView);
@property(nonatomic,copy) void(^didFinishRenderingMap)(MKMapView* mapView, BOOL fullyRendered);
@property(nonatomic,copy) MKAnnotationView*(^viewForAnnotation)(MKMapView* mapView, id <MKAnnotation> annotation);
@property(nonatomic,copy) void(^didAddAnnotationViews)(MKMapView* mapView, NSArray* views);
@property(nonatomic,copy) void(^calloutAccessoryControlTapped)(MKMapView* mapView, MKAnnotationView* view, UIControl* control);
@property(nonatomic,copy) void(^didSelectAnnotationView)(MKMapView* mapView, MKAnnotationView* view);
@property(nonatomic,copy) void(^didDeselectAnnotationView)(MKMapView* mapView, MKAnnotationView* view);
@property(nonatomic,copy) void(^willStartLocatingUser)(MKMapView* mapView);
@property(nonatomic,copy) void(^didStopLocatingUser)(MKMapView* mapView);
@property(nonatomic,copy) void(^didUpdateUserLocation)(MKMapView* mapView, MKUserLocation* userLocation);
@property(nonatomic,copy) void(^didFailToLocateUser)(MKMapView* mapView, NSError* error);
@property(nonatomic,copy) void(^annotationViewDidChangeDragState)(MKMapView* mapView, MKAnnotationView* view, MKAnnotationViewDragState newState, MKAnnotationViewDragState oldState);
@property(nonatomic,copy) void(^didChangeUserTrackingMode)(MKMapView* mapView, MKUserTrackingMode mode, BOOL animated);
@property(nonatomic,copy) MKOverlayRenderer*(^rendererForOverlay)(MKMapView* mapView, id <MKOverlay> overlay);
@property(nonatomic,copy) void(^didAddOverlayRenderers)(MKMapView* mapView, NSArray* renderers);
@property(nonatomic,copy) MKOverlayView*(^viewForOverlay)(MKMapView* mapView, id <MKOverlay> overlay);
@property(nonatomic,copy) void(^didAddOverlayViews)(MKMapView* mapView, NSArray* overlayViews);


@end
