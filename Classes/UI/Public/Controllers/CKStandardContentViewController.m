//
//  CKStandardContentViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKStandardContentViewController.h"
#import "CKResourceManager.h"
#import "UIImageView+URL.h"

@interface CKStandardContentViewController ()

@end

@implementation CKStandardContentViewController

- (void)dealloc{
    //  [_title release]; from super class
    [_subtitle release];
    [_imageURL release];
    [_defaultImageName release];
    [super dealloc];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title action:(void(^)())action{
    return [self controllerWithTitle:title subtitle:nil defaultImageName:nil imageURL:nil action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle action:(void(^)())action{
    return [self controllerWithTitle:title subtitle:subtitle defaultImageName:nil imageURL:nil action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)())action{
    return [self controllerWithTitle:title subtitle:nil defaultImageName:nil imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageURL:(NSURL*)imageURL action:(void(^)())action{
    return [self controllerWithTitle:title subtitle:subtitle defaultImageName:nil imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title imageName:(NSString*)imageName action:(void(^)())action{
    return [self controllerWithTitle:title subtitle:nil imageName:imageName action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageName:(NSString*)imageName action:(void(^)())action{
    NSString* filePath = [CKResourceManager pathForImageNamed:imageName];
    NSURL* imageURL = filePath ? [NSURL fileURLWithPath:filePath] : nil;
    return [self controllerWithTitle:title subtitle:subtitle defaultImageName:nil imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)())action{
    return [self controllerWithTitle:title subtitle:nil defaultImageName:defaultImageName imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)())action{
    CKStandardContentViewController* controller = [[[[self class] alloc]init]autorelease];
    controller.title = title;
    controller.subtitle = subtitle;
    controller.imageURL = imageURL;
    controller.defaultImageName = defaultImageName;
    controller.didSelectBlock = action;
    controller.accessoryType = action ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    controller.flags = action ? CKViewControllerFlagsSelectable : CKViewControllerFlagsNone;
    return controller;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIImageView* imageView = [[[UIImageView alloc]init]autorelease];
    imageView.name = @"ImageView";
    imageView.minimumHeight = 44;
    
    UILabel* titleLabel = [[[UILabel alloc]init]autorelease];
    titleLabel.name = @"TitleLabel";
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.numberOfLines = 0;
    titleLabel.margins = UIEdgeInsetsMake(10,10,10,10);
    
    UILabel* subtitleLabel = [[[UILabel alloc]init]autorelease];
    subtitleLabel.name = @"SubtitleLabel";
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.margins = UIEdgeInsetsMake(10,10,10,10);
    
    CKVerticalBoxLayout* vbox = [[CKVerticalBoxLayout alloc]init];
    vbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[titleLabel,subtitleLabel]];
    
    CKHorizontalBoxLayout* hbox = [[CKHorizontalBoxLayout alloc]init];
    hbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[imageView,vbox]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hbox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIImageView* imageView = [self.view viewWithName:@"ImageView"];
    if(self.defaultImageName){
        imageView.image = [CKResourceManager imageNamed:self.defaultImageName];
    }else{
        imageView.image = nil;
    }
    
    if(self.imageURL){
        imageView.hidden = NO;
        [imageView loadImageWithUrl:self.imageURL completion:^(UIImage *image, NSError *error) {
        }];
    }else{
        imageView.hidden = YES;
    }
    
    UILabel* titleLabel = [self.view viewWithName:@"TitleLabel"];
    titleLabel.hidden = (self.title == nil);
    titleLabel.text = self.title;
    
    UILabel* subtitleLabel = [self.view viewWithName:@"SubtitleLabel"];
    subtitleLabel.hidden = (self.subtitle == nil);
    subtitleLabel.text = self.subtitle;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    UIImageView* imageView = [self.view viewWithName:@"ImageView"];
    [imageView cancelNetworkOperations];
}

@end