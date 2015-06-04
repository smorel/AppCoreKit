//
//  CKPropertyVectorViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

/**
 */
@interface CKPropertyVector : NSObject
@property(nonatomic,retain) CKProperty* property;
@property(nonatomic,retain) NSArray* editableProperties;

- (id)initWithProperty:(CKProperty*)property;

+ (CKPropertyVector*)vectorForPointProperty:(CKProperty*)property;
+ (CKPropertyVector*)vectorForSizeProperty:(CKProperty*)property;
+ (CKPropertyVector*)vectorForRectProperty:(CKProperty*)property;
+ (CKPropertyVector*)vectorForEdgeInsetsProperty:(CKProperty*)property;
+ (CKPropertyVector*)vectorForLocationCoordinate2DProperty:(CKProperty*)property;
+ (CKPropertyVector*)vectorForAffineTransformProperty:(CKProperty*)property;

@end



/** CKPropertyVectorViewController is the base class providing the mechanism to display and edit properties composed by several floating values like CGPoint, CGSize, CGRect, ...
 */
@interface CKPropertyVectorViewController : CKPropertyViewController

/**
 */
+ (BOOL)compatibleWithProperty:(CKProperty*)property;

/**
 */
- (instancetype)initWithPropertyVector:(CKPropertyVector*)vector readOnly:(BOOL)readOnly;

/**
 */
+ (instancetype)controllerWithPropertyVector:(CKPropertyVector*)vector readOnly:(BOOL)readOnly;

/** You can specify the order and a selected amount of component you want to display.
 For example if display a solid color with no alpha, you can specify [ @"red", "@green", @"blue" ]
 If you just want to display the x component of a rectangle or a point you can specify [ @"x" ]
 
 Default value is nil meaning displaying all the components.
 */
@property(nonatomic,retain) NSSet* components;

@end
