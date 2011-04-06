//
//  CKFormTableViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-06.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKObjectTableViewController.h"
#import "CKTableViewCellController.h"
#import "CKModelObject.h"

@interface CKFormSection : CKModelObject{
	NSString* _headerTitle;
	UIView* _headerView;
	NSMutableArray* _cellDescriptors;
}

@property (nonatomic,retain) NSString* headerTitle;
@property (nonatomic,retain) UIView* headerView;
@property (nonatomic,retain) NSMutableArray* cellDescriptors;

- (id)initWithHeaderTitle:(NSString*)title cellDescriptors:(NSArray*)cellDescriptors;
- (id)initWithHeaderView:(UIView*)view cellDescriptors:(NSArray*)cellDescriptors;

@end

typedef void(^CKFormCellInitializeBlock)(CKTableViewCellController* controller);
@interface CKFormCellDescriptor : CKModelObject{
	id _value;
	Class _controllerClass;
	id _controllerStyle;
	
	//OS4
	CKFormCellInitializeBlock _initializeBlock;
	//OS3
	id _initializeTarget;
	SEL _initializeAction;
}

@property (nonatomic,retain) id value;
@property (nonatomic,assign) Class controllerClass;
@property (nonatomic,retain) id controllerStyle;
@property (nonatomic,copy) CKFormCellInitializeBlock block;
@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL action;

- (id)initWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle withBlock:(CKFormCellInitializeBlock)initializeBlock;
- (id)initWithValue:(id)value controllerClass:(Class)controllerClass controllerStyle:(id)controllerStyle target:(id)target action:(SEL)action;

@end

@interface CKFormTableViewController : CKObjectTableViewController {
	NSMutableArray* _sections;
}
@property (nonatomic,retain) NSMutableArray* sections;

- (id)initWithSections:(NSArray*)sections;

@end
