//
//  CKMapCellController.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CloudKit/CKTableViewCellController.h>

@class CKMapCellAnnotation;

@interface CKMapCellController : CKTableViewCellController <MKMapViewDelegate> {
	CKMapCellAnnotation *_annotation;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
