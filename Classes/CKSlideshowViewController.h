//
//  CKSlideShowViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//


#import "CKTableCollectionViewController.h"


/* StyleSheet example for CKSlideShowViewController :

"CKSlideShowViewController" : {
    "UINavigationController" : {
        "navigationBar" : {
            "backgroundImage" : "NONE", //this force to have no background image if 1 has been previously set on the navigation bar
            "barStyle" : "UIBarStyleBlackTranslucent",
            "backBarButtonItem" : {
                "@inherits" : [ "UIBarButtonItem" ],
                "defaultBackgroundImage" : ["button_header_left","15 0"],
                "highlightedBackgroundImage" : ["button_header_left-highlight","15 0"],
                "fontName" : "Helvetica-Bold",
                "fontSize" : "13",
                "defaultTextColor" : "whiteColor",
                "height" : "30",
                "contentEdgeInsets" : "-2 17 0 10"
            }
        },
        
        "UIToolbar" : {
            "backgroundImage" : "NONE", //this force to have no background image if 1 has been previously set on the toolbar
            "barStyle" : "UIBarStyleBlackTranslucent"
        }
    },
    "UITableView" : {
        "backgroundColor" : "blackColor",
        "separatorStyle" : "UITableViewCellSeparatorStyleNone"
    }
}
*/
@interface CKSlideShowViewController : CKTableCollectionViewController

///-----------------------------------
/// @name Creating CKSlideShowViewController Object
///-----------------------------------

/**
 */
+ (id)slideShowControllerWithCollection:(CKCollection *)collection;

/**
 */
+ (id)slideShowControllerWithCollection:(CKCollection *)collection factory:(CKCollectionCellControllerFactory*)factory startAtIndex:(NSInteger)startIndex;

/**
 */
+ (id)slideShowControllerWithCollection:(CKCollection *)collection startAtIndex:(NSInteger)startIndex;

/**
 */
+ (id)slideShowControllerWithImagePaths:(NSArray*)imagePaths startAtIndex:(NSInteger)startIndex;

/**
 */
+ (id)slideShowControllerWithImageURLs:(NSArray*)imageURLs startAtIndex:(NSInteger)startIndex;

///-----------------------------------
/// @name Initializing CKSlideShowViewController Object
///-----------------------------------

/**
 */
- (id)initWithCollection:(CKCollection *)collection;

/**
 */
- (id)initWithCollection:(CKCollection *)collection factory:(CKCollectionCellControllerFactory*)factory startAtIndex:(NSInteger)startIndex;

/**
 */
- (id)initWithCollection:(CKCollection *)collection startAtIndex:(NSInteger)startIndex;

/**
 */
- (id)initWithImagePaths:(NSArray*)imagePaths startAtIndex:(NSInteger)startIndex;

/**
 */
- (id)initWithImageURLs:(NSArray*)imageURLs startAtIndex:(NSInteger)startIndex;

///-----------------------------------
/// @name Customizing the appearance
///-----------------------------------

/**
 */
@property (nonatomic, assign) BOOL shouldHideControls;

/**
 */
@property (nonatomic, assign) BOOL overrideTitleToDisplayCurrentPage;

@end
