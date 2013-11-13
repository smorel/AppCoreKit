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

@interface CKCollectionCellContentViewController ()
@property(nonatomic,retain) CKWeakRef* collectionCellControllerWeakRef;
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@property(nonatomic,retain) UIView* reusableView;
@end

@interface CKCollectionCellController()
- (UIView*)parentControllerView;
@end

@implementation CKCollectionCellContentViewController

- (void)dealloc{
    [self clearBindingsContext];
    
    [_collectionCellControllerWeakRef release];
    [_reusableView release];
    
    [super dealloc];
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
    if(self.isViewLoaded || self.reusableView){
        UIView* view = [self view];
        
        //Support for CKLayout
        if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
            return [view preferedSizeConstraintToSize:size];
        }
        //TODO : Auto layout support !
        else{
        }
        
        //Support for nibs
        return CGSizeMake(MIN(size.width,self.view.width),MIN(size.height,self.view.height));
    }
    return CGSizeMake(0,0);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(self.view.appliedStyle == nil || [self.view.appliedStyle isEmpty]){
        [self applyStyleToSubViews];
    }
}

- (void)applyStyleToSubViews{
    [self.view findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"view"];
    
    //Allows the CKCollectionCellContentViewController to specify style for the contentViewCell
    if(self.contentViewCell.appliedStyle == nil || [self.contentViewCell.appliedStyle isEmpty]){
        [self.contentViewCell setAppliedStyle:nil];
        [self.contentViewCell findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"contentViewCell"];
    }
}

@end
