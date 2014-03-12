//
//  CKMapViewBlockDelegate.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/4/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import "CKMapViewBlockDelegate.h"
#import <objc/runtime.h>

static char MKMapViewBlockDelegateKey;

@interface MKMapView(CKMapViewBlockDelegate)
@property(nonatomic,retain) CKMapViewBlockDelegate* blockDelegate;
@end

@implementation MKMapView(CKMapViewBlockDelegate)
@dynamic blockDelegate;

- (void)setBlockDelegate:(CKMapViewBlockDelegate *)blockDelegate{
    objc_setAssociatedObject(self,
                             &MKMapViewBlockDelegateKey,
                             blockDelegate,
                             OBJC_ASSOCIATION_RETAIN);
}

- (CKMapViewBlockDelegate*)blockDelegate{
    return objc_getAssociatedObject(self, &MKMapViewBlockDelegateKey);
}

@end


@interface CKMapViewBlockDelegate()<MKMapViewDelegate>
@end


@implementation CKMapViewBlockDelegate

- (void)dealloc{
    [_regionWillChangeAnimated release];
    [_regionDidChangeAnimated release];
    [_willStartLoadingMap release];
    [_didFinishLoadingMap release];
    [_didFailLoadingMap release];
    [_willStartRenderingMap release];
    [_didFinishRenderingMap release];
    [_viewForAnnotation release];
    [_didAddAnnotationViews release];
    [_calloutAccessoryControlTapped release];
    [_didSelectAnnotationView release];
    [_didDeselectAnnotationView release];
    [_willStartLocatingUser release];
    [_didStopLocatingUser release];
    [_didUpdateUserLocation release];
    [_didFailToLocateUser release];
    [_annotationViewDidChangeDragState release];
    [_didChangeUserTrackingMode release];
    [_rendererForOverlay release];
    [_didAddOverlayRenderers release];
    [_viewForOverlay release];
    [_didAddOverlayViews release];
    
    [super dealloc];
}

- (id)initWithMapView:(MKMapView*)mapView{
    self = [super init];
    mapView.delegate = self;
    [mapView setBlockDelegate:self];
    return self;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    if(self.regionWillChangeAnimated){
        self.regionWillChangeAnimated(mapView,animated);
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if(self.regionDidChangeAnimated){
        self.regionDidChangeAnimated(mapView,animated);
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView{
    if(self.willStartLoadingMap){
        self.willStartLoadingMap(mapView);
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    if(self.didFinishLoadingMap){
        self.didFinishLoadingMap(mapView);
    }
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    if(self.didFailLoadingMap){
        self.didFailLoadingMap(mapView,error);
    }
}

- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView{
    if(self.willStartRenderingMap){
        self.willStartRenderingMap(mapView);
    }
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered{
    if(self.didFinishRenderingMap){
        self.didFinishRenderingMap(mapView,fullyRendered);
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if(self.viewForAnnotation){
        return self.viewForAnnotation(mapView,annotation);
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    if(self.didAddAnnotationViews){
        self.didAddAnnotationViews(mapView,views);
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    if(self.calloutAccessoryControlTapped){
        self.calloutAccessoryControlTapped(mapView,view,control);
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if(self.didSelectAnnotationView){
        self.didSelectAnnotationView(mapView,view);
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    if(self.didDeselectAnnotationView){
        self.didDeselectAnnotationView(mapView,view);
    }
}

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView{
    if(self.willStartLocatingUser){
        self.willStartLocatingUser(mapView);
    }
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView{
    if(self.didStopLocatingUser){
        self.didStopLocatingUser(mapView);
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    if(self.didUpdateUserLocation){
        self.didUpdateUserLocation(mapView,userLocation);
    }
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    if(self.didFailToLocateUser){
        self.didFailToLocateUser(mapView,error);
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState{
    if(self.annotationViewDidChangeDragState){
        self.annotationViewDidChangeDragState(mapView,view,newState,oldState);
    }
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    if(self.didChangeUserTrackingMode){
        self.didChangeUserTrackingMode(mapView,mode,animated);
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay{
    if(self.rendererForOverlay){
        return self.rendererForOverlay(mapView,overlay);
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers{
    if(self.didAddOverlayRenderers){
        self.didAddOverlayRenderers(mapView,renderers);
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay{
    if(self.viewForOverlay){
        return self.viewForOverlay(mapView,overlay);
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews{
    if(self.didAddOverlayViews){
        self.didAddOverlayViews(mapView,overlayViews);
    }
}


@end
