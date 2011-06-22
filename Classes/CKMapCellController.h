//
//  CKMapCellController.h
//  CloudKit
//
//  Created by Fred Brunel on 10-05-26.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CKTableViewCellController.h"

@class CKMapCellAnnotation;

@interface CKMapCellController : CKTableViewCellController <MKMapViewDelegate> {
	CKMapCellAnnotation *_annotation;
	UIImage *_annotationImage;
	CGPoint _annotationImageOffset;
}

@property (nonatomic, retain) UIImage *annotationImage;
@property (nonatomic, assign) CGPoint annotationImageOffset;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
