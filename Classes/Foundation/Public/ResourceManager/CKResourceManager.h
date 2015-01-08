//
//  CKResourceManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-17.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//CKResourceManagerDidEndUpdatingResourcesNotification
extern NSString* CKResourceManagerDidEndUpdatingResourcesNotification;
extern NSString* CKResourceManagerUpdatedResourcesPathKey;

/**
 [[NSNotificationCenter defaultCenter]addObserverForName:CKResourceManagerDidEndUpdatingResourcesNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
     NSArray* updatedFiles = [notification.userInfo objectForKey:CKResourceManagerUpdatedResourcesPathKey];
     for(NSDictionary* file in updatedFiles){
         NSString* relativePath          = [file objectForKey:CKResourceManagerRelativePathKey];
         NSString* applicationBundlePath = [file objectForKey:CKResourceManagerApplicationBundlePathKey];
         NSString* mostRecentPath        = [file objectForKey:CKResourceManagerMostRecentPathKey];
 
         //DO Something
     }
 }];
 */

//-------------------

//CKResourceManagerFileDidUpdateNotification
extern NSString* CKResourceManagerFileDidUpdateNotification;
extern NSString* CKResourceManagerApplicationBundlePathKey;
extern NSString* CKResourceManagerRelativePathKey;
extern NSString* CKResourceManagerMostRecentPathKey;

/**
 [[NSNotificationCenter defaultCenter]addObserverForName:CKResourceManagerFileDidUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
     NSString* relativePath          = [notification.userInfo objectForKey:CKResourceManagerRelativePathKey];
     NSString* applicationBundlePath = [notification.userInfo objectForKey:CKResourceManagerApplicationBundlePathKey];
     NSString* mostRecentPath        = [notification.userInfo objectForKey:CKResourceManagerMostRecentPathKey];
     //DO Something
 }];
 */

//-------------------



/** This class is a weak bridge to the ResourceManager framework available at https://github.com/wherecloud/ResourceManager
    If the resource manager is used into your app, the calls to CKResouceManager will be redirected to the instanciated ResourceManager.
    Else, the CKResourceManager will redirect the calls to the NSBundle mainBundle.
 */
@interface CKResourceManager : NSObject

/** This returns TRUE if the resource Manager framework is linked and has been initialized.
 */
+ (BOOL)isResourceManagerConnected;


/******************************************************
 Managing bundles
 *****************************************************/

+ (void)registerBundle:(NSBundle*)bundle;

/******************************************************
 Accessing resource files
 *****************************************************/

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext;

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext observer:(id)observer usingBlock:(void(^)(id observer, NSString* path))updateBlock;

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext;

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext localization:(NSString *)localizationName;

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext observer:(id)observer usingBlock:(void(^)(id observer, NSArray* paths))updateBlock;

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext localization:(NSString *)localizationName observer:(id)observer usingBlock:(void(^)(id observer, NSArray* paths))updateBlock;

+ (NSString*)pathForImageNamed:(NSString*)name;

+ (UIImage*)imageNamed:(NSString*)image;

+ (UIImage*)imageNamed:(NSString*)image update:(void(^)(UIImage* image))update;

/******************************************************
 Managing update observers
 *****************************************************/

+ (void)addObserverForResourcesWithExtension:(NSString*)ext object:(id)object usingBlock:(void(^)(id observer, NSArray* paths))updateBlock;

+ (void)addObserverForPath:(NSString*)path object:(id)object usingBlock:(void(^)(id observer, NSString* path))updateBlock;

+ (void)removeObserver:(id)object;

/******************************************************
 Managing HUD
 *****************************************************/

+ (void)setHudTitle:(NSString*)title;

@end


#import "CKResourceManager+UIUpdate.h"