//
//  CKReusableViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-23.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKReusableViewController.h"
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

#import "CKTableViewController.h"
#import "CKCollectionViewController.h"
#import "NSValueTransformer+CGTypes.h"

#import "CKMapViewController.h"

#import "CKWeakRef.h"

@interface NSObject ()

- (void)applySubViewStyle:(NSMutableDictionary*)style
               descriptor:(CKClassPropertyDescriptor*)descriptor
             appliedStack:(NSMutableSet*)appliedStack
                 delegate:(id)delegate;

@end



@interface CKReusableViewController ()
@property(nonatomic,retain) UIView* reusableView;
@property(nonatomic,retain) UIView* contentViewCell;
@property(nonatomic,assign) BOOL isComputingSize;
@property(nonatomic,copy) CKLayoutBoxInvalidatedBlock layoutInvalidateBlock;
@end


@implementation CKReusableViewController

- (void)dealloc{
    [self prepareForDealloc];
    
    [self clearBindingsContext];
    
    [_layoutInvalidateBlock release];
    [_didHighlightBlock release];
    [_didUnhighlightBlock release];
    [_didSelectBlock release];
    [_didSelectAccessoryBlock release];
    [_didDeselectBlock release];
    [_didRemoveBlock release];
    [_reusableView release];
    [_contentViewCell release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CKStyleManagerDidReloadNotification object:nil];
    
    [super dealloc];
}

- (void)prepareForDealloc{
    if(self.state == CKViewControllerStateDidAppear){
        [self viewWillDisappear:NO];
        [self viewDidDisappear:NO];
    }
    
    if([self isViewLoaded]){
        [self prepareForReuseUsingContentView:nil contentViewCell:nil];
        self.view.invalidatedLayoutBlock = nil;
    }
}

- (NSString*)reuseIdentifier{
	NSMutableDictionary* controllerStyle = [self controllerStyle];
	return [NSString stringWithFormat:@"%@-<%p>",[[self class] description],controllerStyle];
}

- (void)styleManagerDidUpdate:(NSNotification*)notification{
    
    if(!self.view){
        return;
    }
    
    if(notification.object == [self styleManager]){
        [self resourceManagerReloadUI];
    }
}

- (NSIndexPath*)indexPath{
    if([self.containerViewController respondsToSelector:@selector(indexPathForController:)]){
        return [self.containerViewController performSelector:@selector(indexPathForController:) withObject:self];
    }
    return nil;
}

- (BOOL)isHeaderViewController{
    return [self.indexPath isSectionHeaderIndexPath];
}

- (BOOL)isFooterViewController{
    return [self.indexPath isSectionFooterIndexPath];
}

- (UIView*) contentViewCell{
    return _contentViewCell;
}

- (UIView*) contentView{
    if([self.containerViewController respondsToSelector:@selector(contentView)])
        return [self.containerViewController performSelector:@selector(contentView) withObject:nil];
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
    if(contentView == nil && self.view){
        self.view.invalidatedLayoutBlock = nil;
    }
    
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
        // if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
            returnSize = [view preferredSizeConstraintToSize:size];
        //}
        //TODO : Auto layout support !
        //else{
        //    returnSize = CGSizeMake(view.width,self.estimatedRowHeight);
        //}
        
        if(returnSize.height <= 0){
            returnSize = CGSizeMake(view.width,self.estimatedSize.height);
        }
        
        self.isComputingSize = NO;
        
        return returnSize;
    }else{
         UIView* cell = nil;
        if(!cell){
            cell = [[UIView alloc]init];//release called later
            cell.flexibleSize = YES;
        }
        
        
        //cell.frame = CGRectMake(0, 0, self.containerViewController.view.width, 1);
        [self prepareForReuseUsingContentView:cell contentViewCell:cell];
        
        [self viewDidLoad];
        [self viewWillAppear:NO];
        [self viewDidAppear:NO];
        
        [cell layoutSubviews];
        
        //Support for CKLayout
        CGSize returnSize = CGSizeMake(0,0);
        //Support for CKLayout
        // if(view.layoutBoxes != nil && view.layoutBoxes.count > 0){
        returnSize = [cell preferredSizeConstraintToSize:size];
        //}
        //TODO : Auto layout support !
        //else{
        //    returnSize = CGSizeMake(view.width,self.estimatedRowHeight);
        //}
        
        if(returnSize.height <= 0){
            returnSize = CGSizeMake(self.view.width,self.estimatedSize.height);
        }
        
        [self viewWillDisappear:NO];
        [self viewDidDisappear:NO];
        
        [self.view clearBindingsContext];
        
        [self prepareForReuseUsingContentView:nil contentViewCell:nil];
        
        [cell release];
        
        self.isComputingSize = NO;
        
        return returnSize;
    }
    
    self.isComputingSize = NO;
    
    return CGSizeMake(0,0);
}


- (void)postInit{
    [super postInit];
    
    self.estimatedSize = CGSizeMake(320,44);
    self.flags = CKViewControllerFlagsSelectable;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleManagerDidUpdate:) name:CKStyleManagerDidReloadNotification object:nil];
    
    CKWeakRef* weak = [CKWeakRef weakRefWithObject:self];
    self.layoutInvalidateBlock = ^(NSObject<CKLayoutBoxProtocol>* box){
        [weak.object viewLayoutDidInvalidate];
    };
}

- (void)didSelect{
    if(self.didSelectBlock){
        self.didSelectBlock(self);
    }
}


- (void)didSelectAccessory{
    if(self.didSelectAccessoryBlock){
        self.didSelectAccessoryBlock(self);
    }
}

- (void)didDeselect{
    if(self.didDeselectBlock){
        self.didDeselectBlock(self);
    }
}

- (void)didRemove{
    if(self.didRemoveBlock){
        self.didRemoveBlock(self);
    }
}

- (void)didHighlight{
    if(self.didHighlightBlock){
        self.didHighlightBlock(self);
    }
}

- (void)didUnhighlight{
    if(self.didUnhighlightBlock){
        self.didUnhighlightBlock(self);
    }
}

- (void)scrollToCell{
    if([self.containerViewController respondsToSelector:@selector(scrollToControllerAtIndexPath:animated:)]){
        
        NSMethodSignature* signature = [self.containerViewController methodSignatureForSelector: @selector(scrollToControllerAtIndexPath:animated:)];
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: signature];
        [invocation setTarget: self.containerViewController];
        [invocation setSelector: @selector(scrollToControllerAtIndexPath:animated:)];
        
        NSIndexPath* i = self.indexPath;
        [invocation setArgument: &i atIndex: 2];
        BOOL bo = YES;
        [invocation setArgument: &bo atIndex: 3];
        
        [invocation invoke];
    }
}


#pragma Managing style


- (void)viewWillAppear:(BOOL)animated{
    [self setupAccessoryView];
    
    //HERE we do not apply style on sub views as we have reuse
    if(self.appliedStyle == nil || [self.appliedStyle isEmpty]){
        NSMutableDictionary* controllerStyle = [self controllerStyle];
        NSMutableSet* appliedStack = [NSMutableSet set];
        
        [[self class] applyStyleByIntrospection:controllerStyle toObject:self appliedStack:appliedStack delegate:nil];
        
        [self applySubViewStyle:controllerStyle
                     descriptor:[self propertyDescriptorForKeyPath:@"view"]
                   appliedStack:appliedStack
                       delegate:self];
        
        //[self applySubViewsStyle:controllerStyle appliedStack:appliedStack  delegate:self];
        /// [[self class] applyStyleByIntrospection:controllerStyle toObject:self appliedStack:appliedStack delegate:nil];
        [self setAppliedStyle:controllerStyle];
    }
    
    [self applyStyleToSubViews];
    
    __block CKReusableViewController* bself = self;
    
    self.view.invalidatedLayoutBlock = self.layoutInvalidateBlock;
    
    [super viewWillAppear:animated];
    
    [self setNeedsDisplay];
}

- (void)viewLayoutDidInvalidate{
    if(self.view.window == nil || self.isComputingSize || self.state != CKViewControllerStateDidAppear){
        return;
    }
    
    NSIndexPath* indexPath = self.indexPath;
    if(!indexPath)
        return;
    
    CGSize currentSize = self.view.bounds.size;
    CGSize size = [self preferredSizeConstraintToSize:CGSizeMake(self.contentViewCell.width,MAXFLOAT)];
    CGFloat diff = fabs(currentSize.height - size.height);
    if(diff < 1 )
        return;
    
    if([self.containerViewController respondsToSelector:@selector(invalidateControllerAtIndexPath:)]){
        [self.containerViewController performSelector:@selector(invalidateControllerAtIndexPath:) withObject:indexPath];
    }
}

- (void)resetStyleOnViewRecursivelly:(UIView*)view{
    [view setAppliedStyle:nil];
    if([view respondsToSelector:@selector(backgroundView)]){
        [[view performSelector:@selector(backgroundView)]setAppliedStyle:nil];
    }
    
    if([view respondsToSelector:@selector(selectedBackgroundView)]){
        [[view performSelector:@selector(selectedBackgroundView)]setAppliedStyle:nil];
    }
}

- (void)reapplyingStyleOnSubviewNamed:(NSString*)name{
    if(self.contentViewCell.appliedStyle == nil || [self.contentViewCell.appliedStyle isEmpty]){
        [self resetStyleOnViewRecursivelly:self.contentViewCell];
        [self applySubViewStyle:[self controllerStyle]
                     descriptor:[self propertyDescriptorForKeyPath:name]
                   appliedStack:[NSMutableSet set]
                       delegate:self];
    }
}

- (void)applyStyleToSubViews{
    //[self reapplyingStyleOnSubviewNamed:@"contentViewCell"];
    if(self.tableViewCell){
        [self reapplyingStyleOnSubviewNamed:@"tableViewCell"];
    }
    if(self.collectionViewCell){
        [self reapplyingStyleOnSubviewNamed:@"collectionViewCell"];
    }
    //[self reapplyingStyleOnSubviewNamed:@"headerFooterView"];
    
    if(self.view.appliedStyle == nil || [self.view.appliedStyle isEmpty]){
        [self.view findAndApplyStyleFromStylesheet:[self controllerStyle] propertyName:@"view"];
    }
}

- (CKStyleViewCornerType)view:(UIView*)view cornerStyleWithStyle:(NSMutableDictionary*)style{
    if(![self.contentView isKindOfClass:[UITableView class]]){
        return CKStyleViewCornerTypeNone;
    }
    
    NSIndexPath* theIndexPath = self.indexPath;
    UITableViewCell* cell = [self.contentViewCell isKindOfClass:[UITableViewCell class]] ? (UITableViewCell*)self.contentViewCell : nil;
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
        return CKStyleViewBorderLocationNone;
    }
    
    NSIndexPath* theIndexPath = self.indexPath;
    UITableViewCell* cell = [self.contentViewCell isKindOfClass:[UITableViewCell class]] ? (UITableViewCell*)self.contentViewCell : nil;
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
    UITableViewCell* cell = [self.contentViewCell  isKindOfClass:[UITableViewCell class]] ? (UITableViewCell*)self.contentViewCell : nil;
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
                /*if(numberOfRows > 1 && theIndexPath.row != numberOfRows-1){
                    return CKStyleViewSeparatorLocationBottom;
                }
                else{
                    return CKStyleViewSeparatorLocationNone;
                }*/
                if(numberOfRows == 1 || theIndexPath.row == 0){
                    return CKStyleViewSeparatorLocationBottom | CKStyleViewSeparatorLocationTop;
                }else{
                    return CKStyleViewSeparatorLocationBottom;
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

- (void)setupAccessoryView{
    if(self.tableViewCell){
        if(self.accessoryType == CKAccessoryActivityIndicator){
            UIActivityIndicatorView* activityIndicator = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]autorelease];
            self.tableViewCell.accessoryType = UITableViewCellAccessoryNone;
            self.tableViewCell.accessoryView = activityIndicator;
            [activityIndicator startAnimating];
        }else{
            if([self.tableViewCell.accessoryView isKindOfClass:[UIActivityIndicatorView class]]){
                [(UIActivityIndicatorView*)self.tableViewCell.accessoryView stopAnimating];
            }
            self.tableViewCell.accessoryView = nil;
            self.tableViewCell.accessoryType = (UITableViewCellAccessoryType)self.accessoryType;
        }
    }
}

- (void)setAccessoryType:(CKAccessoryType)accessoryType{
    _accessoryType = accessoryType;
    [self setupAccessoryView];
}

- (void)accessoryTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKAccessoryType",
                                                 UITableViewCellAccessoryNone,                   // don't show any accessory view
                                                 UITableViewCellAccessoryDisclosureIndicator,    // regular chevron. doesn't track
                                                 UITableViewCellAccessoryDetailDisclosureButton, // info button w/ chevron. tracks
                                                 UITableViewCellAccessoryCheckmark,              // checkmark. doesn't track
                                                 UITableViewCellAccessoryDetailButton,
                                                 CKAccessoryNone,
                                                 CKAccessoryDisclosureIndicator,
                                                 CKAccessoryDetailDisclosureButton,
                                                 CKAccessoryDetailButton,
                                                 CKAccessoryCheckmark,
                                                 CKAccessoryActivityIndicator);
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

- (void)setNeedsDisplay{
    if([[self styleManager] isEmpty])
        return;
    
    if(self.tableViewCell){
        CKStyleView* backgroundStyleView = (self.tableViewCell.backgroundView && [self.tableViewCell.backgroundView isKindOfClass:[CKStyleView class]])
            ? (CKStyleView*)self.tableViewCell.backgroundView : nil;
        CKStyleView* selectedBackgroundStyleView = (self.tableViewCell.selectedBackgroundView && [self.tableViewCell.selectedBackgroundView isKindOfClass:[CKStyleView class]])
            ? (CKStyleView*)self.tableViewCell.selectedBackgroundView : nil;
        
        NSMutableDictionary* styleForBackgroundView = nil;
        NSMutableDictionary* styleForSelectedBackgroundView = nil;
        if(backgroundStyleView || selectedBackgroundStyleView){
            
            NSMutableDictionary* style = [self controllerStyle];
            NSMutableDictionary* tableViewCellStyle = [style styleForObject:self.tableViewCell  propertyName:@"tableViewCell"];
            
            if(backgroundStyleView){
                styleForBackgroundView = [tableViewCellStyle styleForObject:self.tableViewCell.backgroundView  propertyName:@"backgroundView"];
            }
            if(selectedBackgroundStyleView){
                styleForSelectedBackgroundView = [tableViewCellStyle styleForObject:self.tableViewCell.selectedBackgroundView  propertyName:@"selectedBackgroundView"];
            }
        }
        
        
        if(styleForBackgroundView){
            backgroundStyleView.corners = [self view:self.tableViewCell.backgroundView cornerStyleWithStyle:styleForBackgroundView];
            backgroundStyleView.borderLocation = [self view:self.tableViewCell.backgroundView borderStyleWithStyle:styleForBackgroundView];
            backgroundStyleView.separatorLocation = [self view:self.tableViewCell.backgroundView separatorStyleWithStyle:styleForBackgroundView];
            [backgroundStyleView setNeedsLayout];
        }
        
        if(styleForSelectedBackgroundView){
            selectedBackgroundStyleView.corners = [self view:self.tableViewCell.selectedBackgroundView cornerStyleWithStyle:styleForSelectedBackgroundView];
            selectedBackgroundStyleView.borderLocation = [self view:self.tableViewCell.selectedBackgroundView borderStyleWithStyle:styleForSelectedBackgroundView];
            selectedBackgroundStyleView.separatorLocation = [self view:self.tableViewCell.selectedBackgroundView separatorStyleWithStyle:styleForSelectedBackgroundView];
            [selectedBackgroundStyleView setNeedsLayout];
        }
    }
}


- (void)resourceManagerReloadUI{
    [super resourceManagerReloadUI];
    
    id<CKSectionContainerDelegate> parentController = (id<CKSectionContainerDelegate>)[self containerViewControllerConformsToProtocol:@protocol(CKSectionContainerDelegate) ];
    if(parentController){
        [parentController invalidateControllerAtIndexPath:self.indexPath];
    }
}

- (CGSize)estimatedSize{
    if(self.appliedStyle == nil){
        if([[self controllerStyle]containsObjectForKey:@"estimatedSize"]){
            id object = [[self controllerStyle]objectForKey:@"estimatedSize"];
            _estimatedSize = [NSValueTransformer convertCGSizeFromObject:object];
        }
    }
    return _estimatedSize;
}

@end


@implementation NSIndexPath(CKReusableViewController)

+ (NSIndexPath*)indexPathForHeaderInSection:(NSInteger)section{
    return [NSIndexPath indexPathForItem:-1 inSection:section];
}

- (BOOL)isSectionHeaderIndexPath{
    return self.item == -1;
}

+ (NSIndexPath*)indexPathForFooterInSection:(NSInteger)section{
    return [NSIndexPath indexPathForItem:-2 inSection:section];
}

- (BOOL)isSectionFooterIndexPath{
    return self.item == -2;
}

@end

