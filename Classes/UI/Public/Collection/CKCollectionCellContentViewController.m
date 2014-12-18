//
//  CKCollectionCellContentViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionCellContentViewController.h"
#import "NSObject+Bindings.h"
#import "UIView+Positioning.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "CKLayoutBox.h"
#import "UIView+CKLayout.h"
#import "CKContainerViewController.h"
#import "CKStyleManager.h"
#import "CKResourceManager.h"
#import "CKResourceDependencyContext.h"

@interface CKCollectionViewController () 
- (void)updateSizeForControllerAtIndexPath:(NSIndexPath*)index;
@end

@interface CKCollectionCellContentViewController ()
@property(nonatomic,retain) CKWeakRef* collectionCellControllerWeakRef;
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@property(nonatomic,retain) UIView* reusableView;
@property(nonatomic,assign) BOOL isComputingSize;
@end

@interface CKCollectionCellController()
- (UIView*)parentControllerView;
@end

@implementation CKCollectionCellContentViewController

- (void)dealloc{
    [self clearBindingsContext];
    
    [_collectionCellControllerWeakRef release];
    [_reusableView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CKStyleManagerDidReloadNotification object:nil];
    
    [super dealloc];
}

- (NSString*)reuseIdentifier{
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	return [NSString stringWithFormat:@"%@-<%p>",[[self class] description],controllerStyle];
}

- (id)init{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleManagerDidUpdate:) name:CKStyleManagerDidReloadNotification object:nil];
    NSLog(@"%@, Register to CKStyleManagerDidReloadNotification",[self class]);
    return self;
}

- (void)styleManagerDidUpdate:(NSNotification*)notification{
    NSLog(@"%@, did receive style Notification",[self class]);
    
    if(!self.view){
        NSLog(@"%@, no view",[self class]);
        return;
    }
    
    
    if(notification.object == [self styleManager]){
        NSLog(@"%@, YEAHHHHH !",[self class]);
        [self resourceManagerReloadUI];
    }else{
        NSLog(@"%@, not the right style manager",[self class]);
    }
}

- (void)setCollectionCellController:(CKCollectionCellController *)c{
    self.collectionCellControllerWeakRef = [CKWeakRef weakRefWithObject:c];
    [self setContainerViewController:c.containerController];
}

- (CKCollectionCellController*)collectionCellController{
    return [self.collectionCellControllerWeakRef object];
}

- (id)value{
    return [self.collectionCellController value];
}

- (NSIndexPath*)indexPath{
    return [self.collectionCellController indexPath];
}

- (CKCollectionViewController*)collectionViewController{
    return [self.collectionCellController containerController];
}


- (UIView*) contentViewCell{
    return  self.collectionCellController.view;
}

- (UIView*) contentView{
    return  [self.collectionViewController contentView];
}

- (UIView*)view{
    if(self.reusableView)
        return self.reusableView;
    
    return [super view];
}

- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell{
    self.reusableView = contentView;
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    self.isComputingSize = YES;
    if(self.isViewLoaded || self.reusableView){
        UIView* view = [self view];
        
        //Support for CKLayout
        if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
            return [view preferredSizeConstraintToSize:size];
        }
        //TODO : Auto layout support !
        else{
        }
        
        self.isComputingSize = NO;
        
        //Support for nibs
        return CGSizeMake(MIN(size.width,self.view.width),MIN(size.height,self.view.height));
    }
    
    self.isComputingSize = NO;
    
    return CGSizeMake(0,0);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //HERE we do not apply style on sub views as we have reuse
    if(self.appliedStyle == nil || [self.appliedStyle isEmpty]){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableSet* appliedStack = [NSMutableSet set];
        [[self class] applyStyleByIntrospection:controllerStyle toObject:self appliedStack:appliedStack delegate:nil];
        [self setAppliedStyle:controllerStyle];
    }
    
    if(self.view.appliedStyle == nil || [self.view.appliedStyle isEmpty]){
        [self applyStyleToSubViews];
    }
    
    __unsafe_unretained CKCollectionCellContentViewController* bself = self;
    
    self.view.invalidatedLayoutBlock = ^(NSObject<CKLayoutBoxProtocol>* box){
        if(bself.view.window == nil || bself.isComputingSize)
            return;
        
        [bself.collectionViewController updateSizeForControllerAtIndexPath:bself.indexPath];
    };
}

- (void)applyStyleToSubViews{
    //Allows the CKCollectionCellContentViewController to specify style for the contentViewCell
    if(self.contentViewCell.appliedStyle == nil || [self.contentViewCell.appliedStyle isEmpty]){
        [self.contentViewCell setAppliedStyle:nil];
        [self.contentViewCell findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"contentViewCell"];
    }
    
    [self.view findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"view"];
}

@end
