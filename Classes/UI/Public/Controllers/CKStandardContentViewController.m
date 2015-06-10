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
#import "CKImageView.h"

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

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title action:(void(^)(CKStandardContentViewController* controller))action{
    return [self controllerWithTitle:title subtitle:nil defaultImageName:nil imageURL:nil action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle action:(void(^)(CKStandardContentViewController* controller))action{
    return [self controllerWithTitle:title subtitle:subtitle defaultImageName:nil imageURL:nil action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    return [self controllerWithTitle:title subtitle:nil defaultImageName:nil imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    return [self controllerWithTitle:title subtitle:subtitle defaultImageName:nil imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action{
    return [self controllerWithTitle:title subtitle:nil imageName:imageName action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action{
    NSString* filePath = [CKResourceManager pathForImageNamed:imageName];
    NSURL* imageURL = filePath ? [NSURL fileURLWithPath:filePath] : nil;
    return [self controllerWithTitle:title subtitle:subtitle defaultImageName:nil imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    return [self controllerWithTitle:title subtitle:nil defaultImageName:defaultImageName imageURL:imageURL action:action];
}

+ (CKStandardContentViewController*)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action{
    CKStandardContentViewController* controller = [[[[self class] alloc]init]autorelease];
    controller.title = title;
    controller.subtitle = subtitle;
    controller.imageURL = imageURL;
    controller.defaultImageName = defaultImageName;
    controller.didSelectBlock = ^(CKReusableViewController* controller){
        action((CKStandardContentViewController*)controller);
    };
    controller.accessoryType = action ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    controller.flags = action ? CKViewControllerFlagsSelectable : CKViewControllerFlagsNone;
    return controller;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
    
    CKImageView* imageView = [[[CKImageView alloc]init]autorelease];
    imageView.name = @"ImageView";
    imageView.animateLoadingOfImagesLoadedFromCache = NO;
    // imageView.flexibleHeight = YES;
    
    UILabel* titleLabel = [[[UILabel alloc]init]autorelease];
    titleLabel.name = @"TitleLabel";
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.numberOfLines = 0;
    
    UILabel* subtitleLabel = [[[UILabel alloc]init]autorelease];
    subtitleLabel.name = @"SubtitleLabel";
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.numberOfLines = 0;
    subtitleLabel.marginTop = 10;
    
    CKVerticalBoxLayout* vbox = [[[CKVerticalBoxLayout alloc]init]autorelease];
    vbox.horizontalAlignment = CKLayoutHorizontalAlignmentLeft;
    vbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[titleLabel,subtitleLabel]];
    vbox.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    CKHorizontalBoxLayout* hbox = [[[CKHorizontalBoxLayout alloc]init]autorelease];
    hbox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[imageView,vbox]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hbox]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setupImageView];
    [self setupTitle];
    [self setupSubtitle];
}

- (void)setupTitle{
    UILabel* titleLabel = [self.view viewWithName:@"TitleLabel"];
    titleLabel.hidden = (self.title == nil);
    titleLabel.text = self.title;
}

- (void)setupSubtitle{
    UILabel* subtitleLabel = [self.view viewWithName:@"SubtitleLabel"];
    subtitleLabel.hidden = (self.subtitle == nil);
    subtitleLabel.text = self.subtitle;
}

- (void)setupImageView{
    CKImageView* imageView = [self.view viewWithName:@"ImageView"];
    
    if(self.defaultImageName){
        imageView.defaultImage = [CKResourceManager imageNamed:self.defaultImageName];
    }
    
    imageView.imageURL = nil;
    imageView.image = imageView.defaultImage;
    
    if(self.imageURL){
        imageView.imageURL = self.imageURL;
    }
    
    imageView.hidden = (self.defaultImageName == nil && self.imageURL == nil);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}


- (void)setTitle:(NSString *)title{
    [super setTitle:title];
    
    if(self.state == CKViewControllerStateDidAppear){
        [self setupTitle];
    }
}

- (void)setSubtitle:(NSString *)subtitle{
    [_subtitle release];
    _subtitle = [subtitle retain];
    
    if(self.state == CKViewControllerStateDidAppear){
        [self setupSubtitle];
    }
}

- (void)setImageURL:(NSURL *)imageURL{
    [_imageURL release];
    _imageURL = [imageURL retain];
    
    if(self.state == CKViewControllerStateDidAppear){
        [self setupImageView];
    }
}

@end
