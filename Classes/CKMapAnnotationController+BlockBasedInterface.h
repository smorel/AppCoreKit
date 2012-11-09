//
//  CKMapAnnotationController+BlockBasedInterface.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKMapAnnotationController.h"

/**
 */
@interface CKMapAnnotationController (CKBlockBasedInterface)

///-----------------------------------
/// @name Customizing Map Annotation Controller Behaviour
///-----------------------------------

/**
 */
- (void)setDeallocBlock:(void(^)(CKMapAnnotationController* controller))block;

/**
 */
- (void)setInitBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block;

/**
 */
- (void)setSetupBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block;

/**
 */
- (void)setSelectionBlock:(void(^)(CKMapAnnotationController* controller))block;

/**
 */
- (void)setDeselectionBlock:(void(^)(CKMapAnnotationController* controller))block;

/**
 */
- (void)setAccessorySelectionBlock:(void(^)(CKMapAnnotationController* controller))block;

/**
 */
- (void)setViewDidAppearBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block;

/**
 */
- (void)setViewDidDisappearBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block;

/**
 */
- (void)setLayoutBlock:(void(^)(CKMapAnnotationController* controller, MKAnnotationView* view))block;

@end