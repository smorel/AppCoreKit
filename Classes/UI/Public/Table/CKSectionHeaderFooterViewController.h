//
//  CKSectionHeaderFooterViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-19.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import <AppCoreKit/AppCoreKit.h>

typedef NS_ENUM(NSInteger,CKSectionViewControllerType){
    CKSectionViewControllerTypeHeader,
    CKSectionViewControllerTypeFooter
};


/** CKSectionHeaderFooterViewController provides the logic to display table view cell header/footer like content with the desired degree of customization.
 
 #LAYOUT
 
 - default view padding is 10 10 20 10, flexibleSize is NO so that it fits the height of the content
 
 If type is CKSectionViewControllerTypeHeader:
 
 - default appearance for TextLabel is bold system font of size 17, black color, numberOfLines 1, aligned left

 
 <pre>
 ****************************************************
 |                                                  |
 | [TextLabel]                                      |
 |                                                  |
 ****************************************************
 </pre>
 
 If type is CKSectionViewControllerTypeFooter:
 
 - default appearance for TextLabel is system font of size 14, black color, numberOfLines 0, aligned center, flexible width
 
 <pre>
 ****************************************************
 |                                                  |
 | [                 TextLabel                    ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKSectionHeaderFooterViewController, you can customize the appearance of this view controller as follow:
 
 <pre>
 {
     //Target your controller by type and the property path that you set when initializing your property
 
     "CKSectionHeaderFooterViewController[type=CKSectionViewControllerTypeHeader]" : {
 
        "view" : {
           //customize the view containing the labels and text input views here
        },
 
        "UILabel[name=TextLabel]" : {
           //customize any appearance or layout properties of UILabel
              (font, textColor, margins, ...)
         }
     },
 
 
     "CKSectionHeaderFooterViewController[type=CKSectionViewControllerTypeFooter]" : {
 
         "view" : {
            //customize the view containing the labels and text input views here
         },
 
         "UILabel[name=TextLabel]" : {
           //customize any appearance or layout properties of UILabel
               (font, textColor, margins, ...)
         }
     }
 }
 </pre>
 
 */
@interface CKSectionHeaderFooterViewController : CKReusableViewController

/**
 */
+ (instancetype)controllerWithType:(CKSectionViewControllerType)type text:(NSString*)text;

/**
 */
@property(nonatomic,assign) CKSectionViewControllerType type;

/**
 */
@property(nonatomic,retain) NSString* text;

@end
