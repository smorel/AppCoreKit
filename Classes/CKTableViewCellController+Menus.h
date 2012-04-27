//
//  CKTableViewCellController+Menus.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-04.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"

@interface CKTableViewCellController(CKMenus)

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action;


+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action;

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;
+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action;

@end