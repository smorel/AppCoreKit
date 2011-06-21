//
//  CKNibCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-13.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"
#import <CloudKit/CKNSObject+Bindings.h>

typedef enum{
	CKNibCellControllerModeNone,
	CKNibCellControllerModePortrait,
	CKNibCellControllerModeLandscape
}CKNibCellControllerMode;

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
@property (nonatomic,assign) CKNibCellControllerMode currentMode;
@property (nonatomic,assign) BOOL autoresizeViewsOnInsertion;

@property (nonatomic,retain) UIView* portraitView;
@property (nonatomic,retain) UIView* landscapeView;

//PRIVATE
- (void)customizePortraitView:(UIView*)view;
- (void)customizeLandscapeView:(UIView*)view;
- (void)bindValueInPortraitView:(UIView*)view;
- (void)bindValueInLandscapeView:(UIView*)view;
- (void)willDeleteLandscapeView:(UIView*)view;
- (void)willDeletePortraitView:(UIView*)view;

@end
