//
//  CKTableViewCellController+Menus.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-04.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController+Menus.h"
#import "CKTableViewCellController+CKBlockBasedInterface.h"
#import "CKTableViewCellController.h"
#import "CKImageLoader.h"
#import "CKUIImage+Transformations.h"


@implementation CKTableViewCellController (CKMenus)

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil image:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:subTitle image:nil action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil image:image action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle image:(UIImage*)image action:(void(^)(CKTableViewCellController* controller))action{
    CKTableViewCellController* cellController = [CKTableViewCellController cellController];
    cellController.cellStyle = ((subTitle != nil) ? CKTableViewCellStyleSubtitle : CKTableViewCellStyleDefault);
    cellController.flags = ((action != nil) ? CKItemViewFlagSelectable : CKItemViewFlagNone);
    cellController.text = title;
    cellController.detailText = subTitle;
    cellController.image = image;
    cellController.accessoryType = ((action != nil) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    cellController.selectionStyle = ((action != nil) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone);
    if(action != nil){
        [cellController setSelectionBlock:^(CKTableViewCellController *controller) {
            action(controller);
        }];
    }
    return cellController;
}


+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil defaultImage:nil imageURL:imageURL action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:subTitle defaultImage:nil imageURL:imageURL action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil defaultImage:image imageURL:imageURL action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil defaultImage:image imageURL:imageURL imageSize:CGSizeMake(-1,-1) action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil defaultImage:nil imageURL:imageURL imageSize:imageSize action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:subTitle defaultImage:nil imageURL:imageURL imageSize:imageSize action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action{
    return [CKTableViewCellController cellControllerWithTitle:title subtitle:nil defaultImage:image imageURL:imageURL imageSize:imageSize action:action];
}

+ (CKTableViewCellController*)cellControllerWithTitle:(NSString*)title subtitle:(NSString*)subTitle defaultImage:(UIImage*)image imageURL:(NSURL*)imageURL imageSize:(CGSize)imageSize action:(void(^)(CKTableViewCellController* controller))action{
    __block UIImage* croppedImage = image;
    __block UIImage* remoteImage = nil;
    if(imageSize.width >= 0 && imageSize.height >= 0
       && !CGSizeEqualToSize(croppedImage.size, imageSize)){
        croppedImage = [croppedImage imageThatFits:imageSize crop:NO];
    }
    
    CKTableViewCellController* cellController = [CKTableViewCellController cellController];
    cellController.cellStyle = ((subTitle != nil) ? CKTableViewCellStyleSubtitle : CKTableViewCellStyleDefault);
    cellController.flags = ((action != nil) ? CKItemViewFlagSelectable : CKItemViewFlagNone);
    cellController.text = title;
    cellController.detailText = subTitle;
    cellController.image = remoteImage ? remoteImage : croppedImage;
    cellController.accessoryType = ((action != nil) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    cellController.selectionStyle = ((action != nil) ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone);
    if(action != nil){
        [cellController setSelectionBlock:^(CKTableViewCellController *controller) {
            action(controller);
        }];
    }
    
    //ImageURL Management
    __block CKTableViewCellController* bself = cellController;
    
    CKImageLoader* imageLoader = nil;
    if(imageURL){
        imageLoader = [[[CKImageLoader alloc]init]autorelease];
        imageLoader.completionBlock = ^(CKImageLoader* imageLoader, UIImage* image, BOOL loadedFromCache){
            if(imageSize.width >= 0 && imageSize.height >= 0
               && !CGSizeEqualToSize(image.size, imageSize)){
                image = [image imageThatFits:imageSize crop:NO];
            }
            remoteImage = image;
            bself.image = remoteImage;
        };
    }
    
    [cellController setViewDidDisappearBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
        [imageLoader cancel];
    }];
    
    [cellController setSetupBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
        if(!remoteImage){
            [imageLoader loadImageWithContentOfURL:imageURL];
        }
    }];
    
    /* We can do it when setupping now as we have multi-threaded the network.
    [cellController setViewDidAppearBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
        if(!remoteImage){
            [imageLoader loadImageWithContentOfURL:imageURL];
        }
    }];*/
    
    return cellController;
}


@end
