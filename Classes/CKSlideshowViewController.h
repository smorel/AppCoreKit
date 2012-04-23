//
//  CKSlideShowViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-12-08.
//  Copyright (c) 2011 WhereCloud Inc. All rights reserved.
//

/* StyleSheet example for CKSlideshowController2 :

"CKSlideShowViewController" : {
    "UINavigationController" : {
        "navigationBar" : {
            "backgroundImage" : "CRAP", //this force to have no background image if 1 has been previously set on the navigation bar
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
            "backgroundImage" : "CRAP", //this force to have no background image if 1 has been previously set on the toolbar
            "barStyle" : "UIBarStyleBlackTranslucent"
        }
    },
    "UITableView" : {
        "backgroundColor" : "blackColor",
        "separatorStyle" : "UITableViewCellSeparatorStyleNone"
    }
}
*/

#import "CKBindedTableViewController.h"

@interface CKSlideShowViewController : CKBindedTableViewController
@property (nonatomic, assign) BOOL shouldHideControls;

- (id)initWithCollection:(CKCollection *)collection;
- (id)initWithCollection:(CKCollection *)collection factory:(CKItemViewControllerFactory*)factory startAtIndex:(NSInteger)startIndex;
- (id)initWithCollection:(CKCollection *)collection startAtIndex:(NSInteger)startIndex;

- (id)initWithImagePaths:(NSArray*)imagePaths startAtIndex:(NSInteger)startIndex;
- (id)initWithImageURLs:(NSArray*)imageURLs startAtIndex:(NSInteger)startIndex;

@end
