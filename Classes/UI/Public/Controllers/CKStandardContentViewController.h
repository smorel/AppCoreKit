//
//  CKStandardContentViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController.h"


/** CKStandardContentViewController provides the logic to display table view cell like content with the desired degree of customization.
 
 #LAYOUT
 
 - default view padding is 0 0 0 0, flexibleSize is NO so that it fits the height of the content
 - default padding for vertical box containing the labels is 10 10 10 10
 - default margin bottom on *SubtitleLabel*: 10
 - default appearance for TitleLabel is bold system font of size 17, black color, numberOfLines 0
 - default appearance for SubtitleLabel is system font of size 14, black color, numberOfLines 0
 - ImageView is flexible height to match the height of the content with minimum height of 44. width will stretch to fit the image aspect ratio.
 
 
 <pre>
 ****************************************************
 |[         ]                                       |
 |[         ]  [TitleLabel]                         |
 |[ImageView]                                       |
 |[         ]  [SubtitleLabel]                      |
 |[         ]                                       |
 ****************************************************
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKStandardContentViewController, you can customize the appearance of this view controller as follow:
 
 <pre>
 {
     //Target your controller by type and the property path that you set when initializing your property
 
     "CKStandardContentViewController[name=aName]" : {
 
         //You can customize your CKStandardContentViewController properties here. For example:
 
         "view" : {
             //customize the view containing the labels and text input views here
          },
 
          "UILabel[name=TitleLabel]" : {
              //customize any appearance or layout properties of UILabel
                (font, textColor, margins, ...)
          },
 
          "UILabel[name=SubtitleLabel]" : {
              //customize any appearance or layout properties of UILabel
                (font, textColor, margins, ...)
          },
 
          "CKImageView[name=ImageView]" : {
          }
     }
 }
 </pre>
 
 */
@interface CKStandardContentViewController : CKReusableViewController

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle defaultImageName:(NSString*)defaultImageName imageURL:(NSURL*)imageURL action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
+ (instancetype)controllerWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageName:(NSString*)imageName action:(void(^)(CKStandardContentViewController* controller))action;

/**
 */
@property(nonatomic,retain) NSString* title;

/**
 */
@property(nonatomic,retain) NSString* subtitle;

/**
 */
@property(nonatomic,retain) NSURL* imageURL;

/**
 */
@property(nonatomic,retain) NSString* defaultImageName;


@end
