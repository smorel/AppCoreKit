//
//  CKSnapshotController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/5/2014.
//  Copyright (c) 2014 Sebastien Morel. All rights reserved.
//

#import <UIKit/UIKit.h>

/** A class for easily define view for offscreen snapshots
    This is particularily usefull if you want to create an image from a complex view with logic for setting it as a passbook strip or background image as weel as for custom transitions between view controllers.
 */
@interface CKSnapshotController : NSObject

/**
 */
+ (CKSnapshotController*)snapshotController;

/** Call this method to snapshot this view controller's view offscreen
    Sequence :
       - viewDidLoad
       - viewWillAppear
       - viewDidAppear
       - delay block : if your view controller that requiers time before snapshot. Call the readyForSnapshot() block when ready. If not, sets it to nil
              For example, maps needs to be fully rendered or Images have to be fetched completely
 
       - When readyForSnapshot() is called:
            - Snapshots the view
            - viewWillDisappear
            - viewDidDisappear
            - completion(snapshot)
 */
- (void)snapshotViewController:(UIViewController*)viewController
                          size:(CGSize)size
                         delay:(void(^)( void(^readyForSnapshot)()) )delay
                    completion:(void(^)(UIImage* image))completion;

/** Call this method to snapshot this view controller's view offscreen.
 
 Sequence :
     - viewDidLoad
 - viewWillAppear
 - viewDidAppear
     - UIViewController(CKSnapshotController) : if the specified viewController has requiersDelayBeforeSnapshot = YES, the snapshot will wait until readyForSnapshot is called on the view controller
 
     - When readyForSnapshot() is called:
     - Snapshots the view
     - viewWillDisappear
     - viewDidDisappear
     - completion(snapshot)
 */
- (void)snapshotViewController:(UIViewController*)viewController
                          size:(CGSize)size
                    completion:(void(^)(UIImage* image))completion;

@end


/**
 */
@interface UIViewController(CKSnapshotController)

/**
 */
@property(nonatomic,assign) BOOL requiersDelayBeforeSnapshot;

/**
 */
- (void)readyForSnapshot;

@end