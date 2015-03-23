//
//  CKResusableViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKResusableViewController.h"
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
#import "CKVersion.h"


#import "CKTableViewCellController.h"
#import "CKTableViewController.h"

@interface NSObject ()

- (void)applySubViewStyle:(NSMutableDictionary*)style
               descriptor:(CKClassPropertyDescriptor*)descriptor
             appliedStack:(NSMutableSet*)appliedStack
                 delegate:(id)delegate;

@end


@interface CKCollectionViewController ()
- (void)updateSizeForControllerAtIndexPath:(NSIndexPath*)index;
@end

@interface CKResusableViewController ()
@property(nonatomic,retain) CKWeakRef* collectionCellControllerWeakRef;
@property(nonatomic,assign,readwrite) CKCollectionCellController* collectionCellController;
@property(nonatomic,retain) UIView* reusableView;
@property(nonatomic,retain) UIView* contentViewCell;
@property(nonatomic,assign) BOOL isComputingSize;
@end

@interface CKCollectionCellController()
- (UIView*)parentControllerView;
@end

@implementation CKResusableViewController

- (void)dealloc{
    [self clearBindingsContext];
    
    [_didSelectBlock release];
    [_collectionCellControllerWeakRef release];
    [_reusableView release];
    [_contentViewCell release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CKStyleManagerDidReloadNotification object:nil];
    
    [super dealloc];
}

- (NSString*)reuseIdentifier{
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	return [NSString stringWithFormat:@"%@-<%p>",[[self class] description],controllerStyle];
}

- (id)init{
    self = [super init];
    self.estimatedRowHeight = 44;
    self.flags = CKViewControllerFlagsSelectable;
    self.state = CKViewControllerStateNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleManagerDidUpdate:) name:CKStyleManagerDidReloadNotification object:nil];
    return self;
}

- (void)setContainerViewController:(UIViewController *)containerViewController{
    [super setContainerViewController:containerViewController];
    [self postInit];
}

- (void)styleManagerDidUpdate:(NSNotification*)notification{
    
    if(!self.view){
        return;
    }
    
    if(notification.object == [self styleManager]){
        [self resourceManagerReloadUI];
    }
}


- (void)resourceManagerReloadUI{
    [super resourceManagerReloadUI];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionCellController invalidateSize];
    });
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
    if(self.collectionCellController )
        return [self.collectionCellController indexPath];
    
    if([self.containerViewController respondsToSelector:@selector(indexPathForController:)]){
        return [self.containerViewController performSelector:@selector(indexPathForController:) withObject:self];
    }
    
    return nil;
}

- (CKViewController*)collectionViewController{
    if(self.collectionCellController)
        return [self.collectionCellController containerController];
    
    return (CKViewController*)self.containerViewController;
}

- (UIView*) contentViewCell{
    if(self.collectionCellController)
        return  self.collectionCellController.view;
    return _contentViewCell;
}

- (UIView*) contentView{
    if([self.collectionViewController respondsToSelector:@selector(contentView)])
        return [self.collectionViewController performSelector:@selector(contentView) withObject:nil];
    return nil;
}

- (UIView*)view{
    if(self.reusableView)
        return self.reusableView;
    
    return [super view];
}

- (BOOL)isViewLoaded{
    if(self.reusableView)
        return YES;
    return [super isViewLoaded];
}

- (void)prepareForReuseUsingContentView:(UIView*)contentView contentViewCell:(UIView*)contentViewCell{
    if(self.state == CKViewControllerStateDidAppear
       || self.state == CKViewControllerStateWillAppear){
        [self viewWillDisappear:NO];
        [self viewDidDisappear:NO];
    }
    
    self.reusableView = contentView;
    self.contentViewCell = contentViewCell;
    contentViewCell.containerViewController = self;
}

- (CGSize)preferredSizeConstraintToSize:(CGSize)size{
    self.isComputingSize = YES;
    if(self.isViewLoaded || self.reusableView){
        UIView* view = [self view];
        
        //Support for nibs
        CGSize returnSize = CGSizeMake(MIN(size.width,self.view.width),MIN(size.height,self.view.height));
        
        //Support for CKLayout
        if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
            returnSize = [view preferredSizeConstraintToSize:size];
        }
        //TODO : Auto layout support !
        else{
            returnSize = CGSizeMake(view.width,self.estimatedRowHeight);
        }
        
        self.isComputingSize = NO;
        
        return returnSize;
    }else{
        UIView* view = [[UIView alloc]init];
        view.frame = CGRectMake(0, 0, size.width, 100);
        [self prepareForReuseUsingContentView:view contentViewCell:view];
        
        [self viewDidLoad];
        [self viewWillAppear:NO];
        [self viewDidAppear:NO];
        
        [view layoutSubviews];
        
        //Support for CKLayout
        CGSize returnSize = CGSizeMake(0,0);
        if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
            returnSize = [view preferredSizeConstraintToSize:size];
        }
        //TODO : Auto layout support !
        else{
            returnSize = CGSizeMake(view.width,self.estimatedRowHeight);
        }
        
        [self viewWillDisappear:NO];
        [self viewDidDisappear:NO];
        
        [view clearBindingsContext];
        
        [self prepareForReuseUsingContentView:nil contentViewCell:nil];
        
        [view release];
        
        self.isComputingSize = NO;
        
        return returnSize;
    }
    
    self.isComputingSize = NO;
    
    return CGSizeMake(0,0);
}


- (void)postInit{
    
}

- (void)didSelect{
    if(self.didSelectBlock){
        self.didSelectBlock();
    }
}

- (BOOL)didRemove{
    return NO;
}

- (UINavigationController*)navigationController{
    return self.collectionViewController.navigationController;
}

- (void)scrollToCell{
    if([self.collectionViewController respondsToSelector:@selector(scrollToControllerAtIndexPath:animated:)]){
        [self.collectionViewController scrollToControllerAtIndexPath:self.indexPath animated:YES];
    }
}


#pragma Managing style

- (void)viewDidLoad{
    [super viewDidLoad];
    self.state = CKViewControllerStateDidLoad;
}

- (void)viewDidUnload{
    [super viewDidUnload];
    self.state = CKViewControllerStateDidUnload;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.state = CKViewControllerStateDidAppear;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.state = CKViewControllerStateWillDisappear;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.state = CKViewControllerStateDidDisappear;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.state = CKViewControllerStateWillAppear;
    
    if(self.tableViewCell){
        self.tableViewCell.accessoryType = self.accessoryType;
    }
    
    //HERE we do not apply style on sub views as we have reuse
    if(self.appliedStyle == nil || [self.appliedStyle isEmpty]){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableSet* appliedStack = [NSMutableSet set];
        [self applySubViewsStyle:controllerStyle appliedStack:appliedStack  delegate:self];
        /// [[self class] applyStyleByIntrospection:controllerStyle toObject:self appliedStack:appliedStack delegate:nil];
        [self setAppliedStyle:controllerStyle];
    }
    
    [self applyStyleToSubViews];
    
    __unsafe_unretained CKResusableViewController* bself = self;
    
    self.view.invalidatedLayoutBlock = ^(NSObject<CKLayoutBoxProtocol>* box){
        if(bself.view.window == nil || bself.isComputingSize || bself.state != CKViewControllerStateDidAppear)
            return;
        
        if(bself.collectionCellController){
            [bself.collectionCellController invalidateSize];
        }
        else if([bself.containerViewController respondsToSelector:@selector(invalidateControllerAtIndexPath:)]){
            [bself.containerViewController performSelector:@selector(invalidateControllerAtIndexPath:) withObject:bself.indexPath];
        }
    };
}

- (void)reapplyingStyleOnSubviewNamed:(NSString*)name{
    if(self.contentViewCell.appliedStyle == nil || [self.contentViewCell.appliedStyle isEmpty]){
        [self.contentViewCell setAppliedStyle:nil];
        [self applySubViewStyle:[self controllerStyle]
                     descriptor:[self propertyDescriptorForKeyPath:name]
                   appliedStack:[NSMutableSet set]
                       delegate:self];
    }

}

- (void)applyStyleToSubViews{
    [self reapplyingStyleOnSubviewNamed:@"contentViewCell"];
    [self reapplyingStyleOnSubviewNamed:@"tableViewCell"];
    [self reapplyingStyleOnSubviewNamed:@"headerFooterView"];
    
    if(self.view.appliedStyle == nil || [self.view.appliedStyle isEmpty]){
        [self.view findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"view"];
    }
}

- (CKStyleViewCornerType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style{
    if(![self.contentView isKindOfClass:[UITableView class]]){
        return CKStyleViewCornerTypeNone;
    }
    
    NSIndexPath* theIndexPath = self.indexPath;
    UITableViewCell* cell = (UITableViewCell*)self.contentViewCell;
    UITableView* tableView = (UITableView*)self.contentView;
    
    CKViewCornerStyle cornerStyle = CKViewCornerStyleTableViewCell;
    if([style containsObjectForKey:CKStyleCornerStyle]){
        cornerStyle = [style cornerStyle];
    }
    
    CKStyleViewCornerType roundedCornerType = CKStyleViewCornerTypeNone;
    switch(cornerStyle){
        case CKViewCornerStyleTableViewCell:{
            if([CKOSVersion() floatValue] < 7){
                
                if(view == cell.backgroundView || view == cell.selectedBackgroundView){
                    if(tableView.style == UITableViewStyleGrouped){
                        NSInteger numberOfRows = [tableView.dataSource tableView:tableView numberOfRowsInSection:theIndexPath.section];
                        if(theIndexPath.row == 0 && numberOfRows > 1){
                            roundedCornerType = CKStyleViewCornerTypeTop;
                        }
                        else if(theIndexPath.row == 0){
                            roundedCornerType = CKStyleViewCornerTypeAll;
                        }
                        else if(theIndexPath.row == numberOfRows-1){
                            roundedCornerType = CKStyleViewCornerTypeBottom;
                        }
                    }
                }
            }
            break;
        }
        case CKViewCornerStyleRounded:{
            roundedCornerType = CKStyleViewCornerTypeAll;
            break;
        }
        case CKViewCornerStyleRoundedTop:{
            roundedCornerType = CKStyleViewCornerTypeTop;
            break;
        }
        case CKViewCornerStyleRoundedBottom:{
            roundedCornerType = CKStyleViewCornerTypeBottom;
            break;
        }
    }
    
    return roundedCornerType;
}

- (CKStyleViewBorderLocation)view:(UIView*)view borderStyleWithStyle:(NSMutableDictionary*)style{
    if(![self.contentView isKindOfClass:[UITableView class]]){
        return CKViewBorderStyleNone;
    }
    
    NSIndexPath* theIndexPath = self.indexPath;
    UITableViewCell* cell = (UITableViewCell*)self.contentViewCell;
    UITableView* tableView = (UITableView*)self.contentView;
    
    CKViewBorderStyle borderStyle = CKViewBorderStyleTableViewCell;
    if([style containsObjectForKey:CKStyleBorderStyle]){
        borderStyle = [style borderStyle];
    }
    
    if(borderStyle & CKViewBorderStyleTableViewCell){
        if(view == cell.backgroundView
           || view == cell.selectedBackgroundView){
            NSInteger numberOfRows = [tableView.dataSource tableView:tableView numberOfRowsInSection:theIndexPath.section];
            if(numberOfRows > 1){
                if(theIndexPath.row == 0){
                    return  CKStyleViewBorderLocationLeft | CKStyleViewBorderLocationTop | CKStyleViewBorderLocationRight;
                }else if(theIndexPath.row == numberOfRows-1){
                    return  CKStyleViewBorderLocationLeft | CKStyleViewBorderLocationBottom | CKStyleViewBorderLocationRight;
                }else{
                    return CKStyleViewBorderLocationLeft | CKStyleViewBorderLocationRight;
                }
            }
            else{
                return CKStyleViewBorderLocationAll;
            }
        }
    }else{
        CKStyleViewBorderLocation viewBorderType = CKStyleViewBorderLocationNone;
        if(borderStyle & CKViewBorderStyleTop){
            viewBorderType |= CKStyleViewBorderLocationTop;
        }
        if(borderStyle & CKViewBorderStyleLeft){
            viewBorderType |= CKStyleViewBorderLocationLeft;
        }
        if(borderStyle & CKViewBorderStyleRight){
            viewBorderType |= CKStyleViewBorderLocationRight;
        }
        if(borderStyle & CKViewBorderStyleBottom){
            viewBorderType |= CKStyleViewBorderLocationBottom;
        }
        return viewBorderType;
    }
    
    return CKStyleViewBorderLocationNone;
}

- (CKStyleViewSeparatorLocation)view:(UIView*)view separatorStyleWithStyle:(NSMutableDictionary*)style{
    if(![self.contentView isKindOfClass:[UITableView class]]){
        return CKStyleViewSeparatorLocationNone;
    }
    
    NSIndexPath* theIndexPath = self.indexPath;
    UITableViewCell* cell = (UITableViewCell*)self.contentViewCell;
    UITableView* tableView = (UITableView*)self.contentView;
    
    CKStyleViewSeparatorLocation separatorType = CKStyleViewSeparatorLocationNone;
    
    CKViewSeparatorStyle separatorStyle = CKViewSeparatorStyleTableViewCell;
    if([style containsObjectForKey:CKStyleSeparatorStyle]){
        separatorStyle = [style separatorStyle];
    }
    
    switch(separatorStyle){
        case CKViewSeparatorStyleTableViewCell:{
            if(view == cell.backgroundView || view == cell.selectedBackgroundView){
                NSInteger numberOfRows = [tableView.dataSource tableView:tableView numberOfRowsInSection:theIndexPath.section];
                if(numberOfRows > 1 && theIndexPath.row != numberOfRows-1){
                    return CKStyleViewSeparatorLocationBottom;
                }
                else{
                    return CKStyleViewSeparatorLocationNone;
                }
            }
            break;
        }
        case CKViewSeparatorStyleTop:    return CKStyleViewSeparatorLocationAll;
        case CKViewSeparatorStyleBottom: return CKStyleViewSeparatorLocationBottom;
        case CKViewSeparatorStyleLeft:   return CKStyleViewSeparatorLocationLeft;
        case CKViewSeparatorStyleRight:  return CKStyleViewSeparatorLocationRight;
    }
    
    return separatorType;
}


- (UIColor*)separatorColorForView:(UIView*)view withStyle:(NSMutableDictionary*)style{
    if(![self.contentView isKindOfClass:[UITableView class]]){
        return nil;
    }
    
    UITableView* tableView = (UITableView*)self.contentView;
    
    BOOL hasSeparator = ([tableView separatorStyle] != UITableViewCellSeparatorStyleNone);
    UIColor* separatorColor = hasSeparator ? [tableView separatorColor] : [UIColor clearColor];
    if([style containsObjectForKey:CKStyleSeparatorColor]){
        separatorColor = [style separatorColor];
    }
    return separatorColor;
}

- (BOOL)object:(id)object shouldReplaceViewWithDescriptor:(CKClassPropertyDescriptor*)descriptor withStyle:(NSMutableDictionary*)style{
    if(style == nil || [style isEmpty] == YES)
        return NO;
    
    if([object isKindOfClass:[UITableViewCell class]]){
        if(([descriptor.name isEqual:@"backgroundView"]
            || [descriptor.name isEqual:@"selectedBackgroundView"]) && [style isEmpty] == NO){
            if([CKOSVersion() floatValue] >= 7){
                UITableViewCell* cell = (UITableViewCell*)object;
                cell.backgroundColor = [UIColor clearColor];
            }
            return YES;
        }
    }
    return NO;
}


- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType{
    _accessoryType = accessoryType;
    
    if(self.tableViewCell){
        self.tableViewCell.accessoryType = self.accessoryType;
    }
}

- (void)accessoryTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewCellAccessoryType",
                                                 UITableViewCellAccessoryNone,                   // don't show any accessory view
                                                 UITableViewCellAccessoryDisclosureIndicator,    // regular chevron. doesn't track
                                                 UITableViewCellAccessoryDetailDisclosureButton, // info button w/ chevron. tracks
                                                 UITableViewCellAccessoryCheckmark,              // checkmark. doesn't track
                                                 UITableViewCellAccessoryDetailButton);
}


- (void)setFlags:(CKViewControllerFlags)flags{
    if(_flags != flags){
        _flags = flags;
        if([self isViewLoaded]){
            if(self.view.window == nil || self.isComputingSize || self.state != CKViewControllerStateDidAppear)
                return;
            
            if([self.containerViewController respondsToSelector:@selector(invalidateControllerAtIndexPath:)]){
                [self.containerViewController performSelector:@selector(invalidateControllerAtIndexPath:) withObject:self.indexPath];
            }
        }
    }
}

@end
