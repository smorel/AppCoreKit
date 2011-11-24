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

- (void)initTableViewCell:(UITableViewCell*)cell{
	cell.clipsToBounds = YES;
	
	if(_portraitNibName != nil){
		self.portraitView = [[[NSBundle mainBundle] loadNibNamed:_portraitNibName owner:nil options:nil] objectAtIndex:0];
		[self customizePortraitView:_portraitView];
	}
	
	if(_landscapeNibName != nil){
		self.landscapeView = [[[NSBundle mainBundle] loadNibNamed:_landscapeNibName owner:nil options:nil] objectAtIndex:0];
		[self customizeLandscapeView:_portraitView];
	}	
}

- (void)setupCell:(UITableViewCell *)cell {
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
	
	CKNibCellControllerMode newMode = self.currentMode;
	if(_landscapeView && _portraitView){
		if(animated){
			CATransition *animation = [CATransition animation];
			animation.duration = [params animationDuration];	
			[cell.contentView.layer addAnimation:animation forKey:nil];
		}
		
		UIInterfaceOrientation interfaceOrientation = [params interfaceOrientation];
		if(UIInterfaceOrientationIsPortrait( interfaceOrientation )){
			if(_landscapeView){
                UIView* toRemove = [cell.contentView viewWithTag:345678];
				[toRemove removeFromSuperview];
                
				if(_autoresizeViewsOnInsertion){
					_portraitView.frame = cell.contentView.bounds;
				}
                _portraitView.tag = 345678;
				[cell.contentView addSubview:_portraitView];
				newMode = CKNibCellControllerModePortrait;
			}
			else{
                UIView* toRemove = [cell.contentView viewWithTag:345678];
				[toRemove removeFromSuperview];
                
				if(_autoresizeViewsOnInsertion){
					_landscapeView.frame = cell.contentView.bounds;
				}
                _landscapeView.tag = 345678;
				[cell.contentView addSubview:_landscapeView];
				newMode = CKNibCellControllerModeLandscape;
			}
		}
	}
	else if(_portraitView){
        UIView* toRemove = [cell.contentView viewWithTag:345678];
        [toRemove removeFromSuperview];
        
		if(_autoresizeViewsOnInsertion){
			_portraitView.frame = cell.contentView.bounds;
		}
        _portraitView.tag = 345678;
		[cell.contentView addSubview:_portraitView];
		newMode = CKNibCellControllerModePortrait;
	}
	else if(_landscapeView){
        UIView* toRemove = [cell.contentView viewWithTag:345678];
        [toRemove removeFromSuperview];
        
		if(_autoresizeViewsOnInsertion){
			_landscapeView.frame = cell.contentView.bounds;
		}
        _landscapeView.tag = 345678;
		[cell.contentView addSubview:_landscapeView];
		newMode = CKNibCellControllerModeLandscape;
	}
	
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