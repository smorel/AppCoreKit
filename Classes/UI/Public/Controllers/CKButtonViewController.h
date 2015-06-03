//
//  CKButtonViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-06-03.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKReusableViewController.h"
#import "UIButton+FlatDesign.h"
#import "UIButton+Style.h"

/* CKButtonViewController provides the logic to display a button with the desired degree of customization.
 
 #LAYOUT
 
 - default view padding is 10 10 10 10, flexibleSize is NO so that it fits the size of the button
 - default contentEdgeInsets of the button is 10 10 10 10
 - default Button text color is black
 - Button has flexibleWidth set to 1
 
 
 <pre>
 ****************************************************
 |                                                  |
 | [                   Button                     ] |
 |                                                  |
 ****************************************************
 </pre>
 
 
 #CUSTOMIZING THE APPEARANCE
 
 *Programatically*
 
  Implement the customizeButtonBlock block of the controller and customize your controller's view and button accordingly.
 
 *Stylesheets*
 
 In the stylesheet of the view controller embedding the CKButtonViewController, you can customize the appearance of this view controller as follow:

<pre>
{
    //Target your controller by type and the property path that you set when initializing your property
    
    "CKButtonViewController[name=aName]" : {

        //You can customize your CKButtonViewController properties here. For example:
        
        "view" : {
            //customize the view containing the labels and text input views here
        },
        
        "UIButton[name=Button]" : {
            //customize any appearance or layout properties of UIButton
        }
    }
}
</pre>
 */
@interface CKButtonViewController : CKReusableViewController

/**
 */
+ (instancetype)controllerWithLabel:(NSString*)label action:(void(^)(CKButtonViewController* controller))action;


/**
 */
+ (instancetype)controllerWithLabel:(NSString*)title imageName:(NSString*)imageName action:(void(^)(CKButtonViewController* controller))action;

/**
 */
@property(nonatomic,retain) NSString* label;

/**
 */
@property(nonatomic,retain) NSString* imageName;

/**
 */
@property(nonatomic,copy) void(^customizeButtonBlock)(CKButtonViewController* controller, UIButton* button);

@end
