//
//  CKPropertyColorViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

/**
 */
@interface CKPropertyColorViewController : CKPropertyViewController


/** Default value is a localized string as follow: _(@"propertyName") that can be customized by setting a key/value in your localization file as follow:
 "propertyName" = "My Title";
 Or simply set the propertyNameLabel property programatically or in your stylesheet in the CKPropertyStringViewController scope.
 */
@property(nonatomic,retain) NSString* propertyNameLabel;

@end
