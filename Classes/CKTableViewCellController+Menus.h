//
//  CKTableViewCellController+Menus.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKImageView.h"

@interface CKTableViewCellController(CKMenus)

///-----------------------------------
/// @name Creating initialized TableViewCell Controllers
///-----------------------------------

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL  spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;


/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;

/**
 */
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize spinnerStyle:(CKImageViewSpinnerStyle)spinnerStyle action:(void(^)(CKTableViewCellController* controller))action;

@end