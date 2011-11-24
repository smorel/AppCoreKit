//
//  CKNibCellController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-13.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNibCellController.h"
#import "CKImageView.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKObjectTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CKUIView+Positioning.h"

#define PORTRAIT_VIEW_TAG 657896
#define LANDSCAPE_VIEW_TAG 982396235


@interface CKNibCellController()
@end

@implementation CKNibCellController
@synthesize portraitNibName = _portraitNibName;
@synthesize landscapeNibName = _landscapeNibName;
@synthesize portraitView = _portraitView;
@synthesize landscapeView = _landscapeView;
@synthesize currentMode = _currentMode;
@synthesize autoresizeViewsOnInsertion = _autoresizeViewsOnInsertion;

- (void)dealloc{
	{
		switch(self.currentMode){
			case CKNibCellControllerModePortrait:{
				if(self.portraitView ){
					[self willDeletePortraitView:self.portraitView];
				}
				break;
			}
			case CKNibCellControllerModeLandscape:{
				if(self.landscapeView ){
					[self willDeleteLandscapeView:self.landscapeView];
				}
				break;
			}
		}
	}
	
	[_portraitNibName release];
	[_landscapeNibName release];
	[_portraitView release];
	[_landscapeView release];
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		self.currentMode = CKNibCellControllerModeNone;
		self.autoresizeViewsOnInsertion = YES;
	}
	return self;
}

+ (NSString*)classIdentifier{
	return [[self class] description];
}


- (CKNibCellControllerMode)setupCell:(UITableViewCell*)cell usingInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	CKNibCellControllerMode newMode = self.currentMode;
	if(_landscapeView && _portraitView){
        if(UIInterfaceOrientationIsPortrait( interfaceOrientation )){
			if(_landscapeView){
                [_landscapeView removeFromSuperview];
				if(_autoresizeViewsOnInsertion){
					_portraitView.frame = cell.contentView.bounds;
				}
				[cell.contentView addSubview:_portraitView];
				newMode = CKNibCellControllerModePortrait;
			}
			else{
                [_portraitView removeFromSuperview];
				if(_autoresizeViewsOnInsertion){
					_landscapeView.frame = cell.contentView.bounds;
				}
				[cell.contentView addSubview:_landscapeView];
				newMode = CKNibCellControllerModeLandscape;
			}
		}
	}
	else if(_portraitView){
        [_landscapeView removeFromSuperview];
		if(_autoresizeViewsOnInsertion){
			_portraitView.frame = cell.contentView.bounds;
		}
		[cell.contentView addSubview:_portraitView];
		newMode = CKNibCellControllerModePortrait;
	}
	else if(_landscapeView){
        [_portraitView removeFromSuperview];
		if(_autoresizeViewsOnInsertion){
			_landscapeView.frame = cell.contentView.bounds;
		}
		[cell.contentView addSubview:_landscapeView];
		newMode = CKNibCellControllerModeLandscape;
	}
    return newMode;
}

- (void)initTableViewCell:(UITableViewCell*)cell{
	cell.clipsToBounds = YES;
	
	if(_portraitNibName != nil){
		UIView* view = [[[NSBundle mainBundle] loadNibNamed:_portraitNibName owner:nil options:nil] objectAtIndex:0];
        cell.height = view.height;
        cell.width = view.width;
        
        self.portraitView = [[[UIView alloc]initWithFrame:cell.contentView.bounds]autorelease];
        self.portraitView.backgroundColor = [UIColor clearColor];
        self.portraitView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.portraitView.tag = PORTRAIT_VIEW_TAG;
        
        [self.portraitView addSubview:view];
        
		[self customizePortraitView:_portraitView];
	}
	
	if(_landscapeNibName != nil){
		UIView* view =[[[NSBundle mainBundle] loadNibNamed:_landscapeNibName owner:nil options:nil] objectAtIndex:0];
        cell.height = view.height;
        cell.width = view.width;
        
        self.landscapeView = [[[UIView alloc]initWithFrame:cell.contentView.bounds]autorelease];
        self.landscapeView.backgroundColor = [UIColor clearColor];
        self.landscapeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.landscapeView.tag = LANDSCAPE_VIEW_TAG;
        
        [self.landscapeView addSubview:view];

		[self customizeLandscapeView:_landscapeView];
	}	
    
    [self setupCell:cell usingInterfaceOrientation:[self.parentController interfaceOrientation]];
}

- (void)setupCell:(UITableViewCell *)cell {
    //Init state from potentially reused cell
    UIView* view = [cell.contentView viewWithTag:PORTRAIT_VIEW_TAG];
    if(view){
        self.currentMode = CKNibCellControllerModePortrait;
        self.portraitView = view;
    }else{
        UIView* view = [cell.contentView viewWithTag:LANDSCAPE_VIEW_TAG];
        if(view){
            self.currentMode = CKNibCellControllerModeLandscape;
            self.landscapeView = view;
        }
    }
    
	[super setupCell:cell];

	switch(self.currentMode){
		case CKNibCellControllerModePortrait:{
			[self bindValueInPortraitView:self.portraitView];
			break;
		}
		case CKNibCellControllerModeLandscape:{
			[self bindValueInLandscapeView:self.landscapeView];
			break;
		}
	}
}

- (void)rotateCell:(UITableViewCell*)cell withParams:(NSDictionary*)params animated:(BOOL)animated{
	[super rotateCell:cell withParams:params animated:animated];
    if(animated){
        CATransition *animation = [CATransition animation];
        animation.duration = [params animationDuration];	
        [cell.contentView.layer addAnimation:animation forKey:nil];
    }
    
    UIInterfaceOrientation interfaceOrientation = [params interfaceOrientation];
    CKNibCellControllerMode newMode = [self setupCell:cell usingInterfaceOrientation:interfaceOrientation];
    
	if(newMode != self.currentMode){
		self.currentMode = newMode;
		[self setupView:self.tableViewCell];
	}
}

+ (CKItemViewFlags)flagsForObject:(id)object withParams:(NSDictionary*)params{
	//Implement in derived class
	return CKItemViewFlagNone;
}

+ (NSValue*)viewSizeForObject:(id)object withParams:(NSDictionary*)params{
	//Implement in derived class
	return [NSValue valueWithCGSize:CGSizeMake(100,44)];
}

- (void)customizePortraitView:(UIView*)view{
	//Implement in derived class
}

- (void)customizeLandscapeView:(UIView*)view{
	//Implement in derived class
}

- (void)bindValueInPortraitView:(UIView*)view{
	//Implement in derived class
}

- (void)bindValueInLandscapeView:(UIView*)view{
	//Implement in derived class
}

- (void)willDeleteLandscapeView:(UIView*)view{
	//Implement in derived class
}

- (void)willDeletePortraitView:(UIView*)view{
	//Implement in derived class
}

@end