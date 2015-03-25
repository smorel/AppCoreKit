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
- (instancetype)initWithPropertyVector:(CKPropertyVector*)vector;

/**
 */
+ (instancetype)controllerWithPropertyVector:(CKPropertyVector*)vector;


/** Default value is a localized string as follow: _(@"propertyName") that can be customized by setting a key/value in your localization file as follow:
 "propertyName" = "My Title";
 Or simply set the propertyNameLabel property programatically or in your stylesheet in the CKPropertyStringViewController scope.
 */
@property(nonatomic,retain) NSString* propertyNameLabel;

@end
