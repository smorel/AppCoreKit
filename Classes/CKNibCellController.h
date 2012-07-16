//
//  CKNibCellController.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"
#import "CKNSObject+Bindings.h"


/** TODO
 */
typedef enum{
	CKNibCellControllerModeNone,
	CKNibCellControllerModePortrait,
	CKNibCellControllerModeLandscape
}CKNibCellControllerMode;


/** TODO
 */
@interface CKNibCellController : CKTableViewCellController {
	NSString* _portraitNibName;
	NSString* _landscapeNibName;
	
	UIView* _portraitView;
	UIView* _landscapeView;
	CKNibCellControllerMode _currentMode;
	
	BOOL _autoresizeViewsOnInsertion;
}

@property (nonatomic,retain) NSString* portraitNibName;
@property (nonatomic,retain) NSString* landscapeNibName;
@property (nonatomic,assign) BOOL autoresizeViewsOnInsertion;

@property (nonatomic,assign,readonly) CKNibCellControllerMode currentMode;
@property (nonatomic,retain,readonly) UIView* portraitView;
@property (nonatomic,retain,readonly) UIView* landscapeView;

//PRIVATE
- (void)customizePortraitView:(UIView*)view;
- (void)customizeLandscapeView:(UIView*)view;
- (void)bindValueInPortraitView:(UIView*)view;
- (void)bindValueInLandscapeView:(UIView*)view;
- (void)willDeleteLandscapeView:(UIView*)view;
- (void)willDeletePortraitView:(UIView*)view;

@end
