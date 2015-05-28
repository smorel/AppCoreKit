//
//  CKCollectionStatusViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-25.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

/** CKCollectionStatusViewController provides the logic to edit and synchronize the current state of a collection with the desired degree of customization.
 It will show an activity indicator while the feedsource is fetching data and the number of objects with custom formats when the feedsource has finished loading.
 
 The formated number of objects will be displayed in the TitleLabel. SubtitleLabel text is customizable on the controller. if subtitleLabel property is nil, the SubtitleLabel will be hidden.
 
 #LAYOUT
 
 While collection's feedsource is fetching data:
 
 - default view padding: 10 10 10 10, flexibleSize is NO so that it fits the height of the content, minimum height is 44
 - ActivityIndicatorView is centered and default style is grey
 - SubtitleLabel is system font of size 14, black color, numberOfLines 1,flexible in width with textAlignment center, marginTop is 10
 
 
 <pre>
 ****************************************************
 |                                                  |
 | ------------ [ActivityIndicatorView] ----------- |
 |                                                  |
 | [               SubtitleLabel                  ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 Else:
 
 - default view padding: 10 10 10 10, flexibleSize is NO so that it fits the height of the content
 - TitleLabel is bold system font of size 17, black color, numberOfLines 1,flexible in width with textAlignment center
 - SubtitleLabel is system font of size 14, black color, numberOfLines 1,flexible in width with textAlignment center, marginTop is 10

 <pre>
 ****************************************************
 |                                                  |
 | [                 TitleLabel                   ] |
 |                                                  |
 | [               SubtitleLabel                  ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKCollectionStatusViewController, you can customize the appearance of this view controller as follow:
 
 <pre>
 {
     //Target your controller by type and the property path that you set when initializing your property
 
     "CKCollectionStatusViewController[name=youtName]" : {
 
         //You can customize your CKCollectionStatusViewController properties here. For example:
         "subtitleLabel" : "Awesome collection!,
 
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
 
          "UIActivityIndicatorView[name=ActivityIndicatorView]" : {
              //customize any appearance or layout properties of UIActivityIndicatorView
                  (activityIndicatorViewStyle, color, ...)
          }
 
      }
 }
 </pre>
 
 */
@interface CKCollectionStatusViewController : CKReusableViewController

/**
 */
- (instancetype)initWithCollection:(CKCollection*)collection;

/**
 */
+ (instancetype)controllerWithCollection:(CKCollection*)collection;

/**
 */
@property(nonatomic,retain,readwrite) CKCollection* collection;

/**
 */
@property(nonatomic,retain) NSString* noObjectTitleFormat;

/**
 */
@property(nonatomic,retain) NSString* oneObjectTitleFormat;

/**
 */
@property(nonatomic,retain) NSString* multipleObjectTitleFormat;

/**
 */
@property(nonatomic,retain) NSString* subtitleLabel;

@end
