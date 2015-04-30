//
//  CKTableViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-18.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKTableViewController.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "NSValueTransformer+Additions.h"
#import "UIView+AutoresizingMasks.h"
#import "UIView+Positioning.h"

//For CKTableViewCell
#import "CKSheetController.h"
#import "CKRuntime.h"
#import <objc/runtime.h>
#import "CKVersion.h"


@interface CKTableViewController ()
@property(nonatomic,retain) NSMutableArray* keyboardObservers;
@property(nonatomic,assign) CGSize lastPresentedKeyboardSize;
@property (nonatomic,retain,readwrite) CKSectionContainer* sectionContainer;
@property (nonatomic, assign, readwrite) NSInteger currentPage;
@property (nonatomic, assign, readwrite) NSInteger numberOfPages;
@property (nonatomic, assign, readwrite) BOOL scrolling;
@property(nonatomic,retain,readwrite) CKPassThroughView* backgroundView;
@property(nonatomic,retain,readwrite) CKPassThroughView* foregroundView;
@end

@implementation CKTableViewController

- (instancetype)init{
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    return self;
}

- (void)postInit{
    [super postInit];
    self.stickySelectionEnabled = NO;
    self.currentPage = 0;
    self.numberOfPages = 0;
    self.scrolling = NO;
    self.sectionContainer = [[[CKSectionContainer alloc]initWithDelegate:self]autorelease];
    self.adjustInsetsOnKeyboardNotification = YES;
    self.endEditingViewWhenScrolling = YES;
}

- (void)dealloc{
    [self.backgroundView removeFromSuperview];
    [self.foregroundView removeFromSuperview];
    [self clearBindingsContextWithScope:@"foregroundView"];
    [self clearBindingsContextWithScope:@"backgroundView"];
    
    [self unregisterForKeyboardNotifications];
    [_sectionContainer release];
    [_backgroundView release];
    [_foregroundView release];
    [super dealloc];
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewStyle",
                                                 UITableViewStylePlain,
                                                 UITableViewStyleGrouped );
}

- (CGSize)contentSizeForViewInPopover{
    return CGSizeMake(self.view.width,MIN(self.view.height,216));
}


#pragma Managing TableHeaderViewController

- (void)setTableHeaderViewController:(CKReusableViewController *)tableHeaderViewController{
    if(_tableHeaderViewController){
        [self dismissTableHeaderView];
    }
    
    [_tableHeaderViewController release];
    _tableHeaderViewController = [tableHeaderViewController retain];
    [_tableHeaderViewController setContainerViewController:self];
    
    if(self.tableView){
        [self presentsTableHeaderView];
    }
}

- (void)dismissTableHeaderView{
    if(self.tableHeaderViewController){
        if(self.tableHeaderViewController.state != CKViewControllerStateDidDisappear){
            [self.tableHeaderViewController viewWillDisappear:NO];
            [self.tableHeaderViewController viewDidDisappear:NO];
        }
        self.tableView.tableHeaderView = nil;
    }
}

- (void)presentsTableHeaderView{
    if(self.tableHeaderViewController){
        UIView* view = self.tableHeaderViewController.view;
        view.flexibleSize = NO;
        
        [self.tableHeaderViewController viewWillAppear:NO];
        CGSize size = [self.tableHeaderViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        view.frame = CGRectMake(0,0,self.tableView.width,size.height);
        self.tableView.tableHeaderView = view;
        [self.tableHeaderViewController viewDidAppear:NO];
    }
}

#pragma Managing TableFooterViewController

- (void)setTableFooterViewController:(CKReusableViewController *)tableFooterViewController{
    if(_tableFooterViewController){
        [self dismissTableFooterView];
    }
    
    [_tableFooterViewController release];
    _tableFooterViewController = [tableFooterViewController retain];
    [_tableFooterViewController setContainerViewController:self];
    
    if(self.tableView){
        [self presentsTableFooterView];
    }
}

- (void)dismissTableFooterView{
    if(self.tableFooterViewController){
        if(self.tableFooterViewController.state != CKViewControllerStateDidDisappear){
            [self.tableFooterViewController viewWillDisappear:NO];
            [self.tableFooterViewController viewDidDisappear:NO];
        }
        self.tableView.tableFooterView = nil;
    }
}

- (void)presentsTableFooterView{
    if(self.tableFooterViewController){
        UIView* view = self.tableFooterViewController.view;
        view.flexibleSize = NO;
        
        [self.tableFooterViewController viewWillAppear:NO];
        CGSize size = [self.tableFooterViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        view.frame = CGRectMake(0,0,self.tableView.width,size.height);
        self.tableView.tableFooterView = view;
        [self.tableFooterViewController viewDidAppear:NO];
    }
}

#pragma Managing Decorator Views

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44;
    
    self.backgroundView = [[[CKPassThroughView alloc]initWithFrame:self.tableView.bounds]autorelease];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.backgroundView.flexibleSize = YES;
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    self.foregroundView = [[[CKPassThroughView alloc]initWithFrame:self.tableView.bounds]autorelease];
    self.foregroundView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.foregroundView.flexibleSize = YES;
    self.foregroundView.backgroundColor = [UIColor clearColor];
    
    
    [self presentsTableHeaderView];
    [self presentsTableFooterView];
}

- (void)presentsBackgroundView{
    if(self.view  && [self.backgroundView superview] == nil){
        [self.view insertSubview:self.backgroundView atIndex:0];
        
        __unsafe_unretained CKTableViewController* bself = self;

        [self beginBindingsContextWithScope:@"backgroundView"];
        [self.tableView bind:@"contentOffset" executeBlockImmediatly:YES withBlock:^(id value) {
            [bself.backgroundView setFrame:CGRectMake(bself.tableView.contentOffset.x,bself.tableView.contentOffset.y,bself.tableView.width,bself.tableView.height) animated:YES];
        }];
        [self.view bind:@"hidden" executeBlockImmediatly:YES withBlock:^(id value) {
            bself.backgroundView.hidden = bself.view.hidden;
        }];
        [self endBindingsContext];
    }
}

- (void)presentsForegroundView{
    if(self.view  && [self.foregroundView superview] == nil){
        [self.view addSubview:self.foregroundView];
        
        __unsafe_unretained CKTableViewController* bself = self;
        
        [self beginBindingsContextWithScope:@"foregroundView"];
        [self.view bind:@"contentOffset" executeBlockImmediatly:YES withBlock:^(id value) {
            [bself.foregroundView setFrame:CGRectMake(bself.tableView.contentOffset.x,bself.tableView.contentOffset.y,bself.tableView.width,bself.tableView.height) animated:YES];
        }];
        [self.view bind:@"hidden" executeBlockImmediatly:YES withBlock:^(id value) {
            bself.foregroundView.hidden = bself.view.hidden;
        }];
        [self endBindingsContext];
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self presentsBackgroundView];
    [self presentsForegroundView];
    [self.tableView layoutIfNeeded];
}
 

#pragma Managing Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self updateNumberOfPages];
    
    [self.sectionContainer handleViewWillAppearAnimated:animated];
    
    if(self.tableHeaderViewController.state != CKViewControllerStateDidAppear){
        [self.tableHeaderViewController viewWillAppear:NO];
    }
    
    if(self.tableFooterViewController.state != CKViewControllerStateDidAppear){
        [self.tableFooterViewController viewWillAppear:NO];
    }
    
    if(self.editing){
        [self.tableView setEditing:YES animated:NO];
    }
    
    [self registerForKeyboardNotifications];
    [self fetchMoreData];
    
    //for(NSIndexPath* indexPath in self.selectedIndexPaths){
    //    [self.pickerView selectRow:indexPath.row inComponent:indexPath.section animated:NO];
    //}
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.sectionContainer handleViewDidAppearAnimated:animated];
    
    if(self.tableHeaderViewController.state != CKViewControllerStateDidAppear){
        [self.tableHeaderViewController viewDidAppear:NO];
    }
    
    if(self.tableFooterViewController.state != CKViewControllerStateDidAppear){
        [self.tableFooterViewController viewDidAppear:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[self.view superview] endEditing:YES];
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    
    [self.sectionContainer handleViewWillDisappearAnimated:animated];
    
    if(self.tableHeaderViewController.state != CKViewControllerStateDidDisappear){
        [self.tableHeaderViewController viewWillDisappear:NO];
    }
    
    if(self.tableFooterViewController.state != CKViewControllerStateDidDisappear){
        [self.tableFooterViewController viewWillDisappear:NO];
    }
    
    [self unregisterForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.sectionContainer handleViewDidDisappearAnimated:animated];
    
    if(self.tableHeaderViewController.state != CKViewControllerStateDidDisappear){
        [self.tableHeaderViewController viewDidDisappear:NO];
    }
    
    if(self.tableFooterViewController.state != CKViewControllerStateDidDisappear){
        [self.tableFooterViewController viewDidDisappear:NO];
    }
}

#pragma Managing Batch Updates

- (void)performBatchUpdates:(void (^)(void))updates
                 completion:(void (^)(BOOL finished))completion{
    [self performBatchUpdates:updates completion:completion preventingUpdates:NO];
}

- (void)performBatchUpdates:(void (^)(void))updates
                 completion:(void (^)(BOOL finished))completion
          preventingUpdates:(BOOL)preventingUpdates{
    if(preventingUpdates){
        [(CKTableView*)self.tableView beginPreventingUpdates];
    }else{
        [(CKTableView*)self.tableView beginUpdates];
    }
    
    if(updates){
        updates();
    }
    if(preventingUpdates){
        [(CKTableView*)self.tableView endPreventingUpdates];
    }else{
        [(CKTableView*)self.tableView endUpdates];
    }
    
    if(completion){
        completion(YES);
    }
}


#pragma mark CKSectionedViewController protocol


- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.tableView insertSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.tableView deleteSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    if(self.state == CKViewControllerStateNone || self.state == CKViewControllerStateDidLoad){
        sectionUpdate();
        return;
    }
    
    sectionUpdate();
    [self performBatchUpdates:^{
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (UIView*)contentView{
    return self.tableView;
}

- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated{
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionNone animated:animated];
}

#pragma mark Managing Content

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sectionContainer.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    return s.controllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    NSString* reuseIdentifier = [controller reuseIdentifier];
    
    CKTableViewCell* cell = (CKTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell){
        cell = [[[CKTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]autorelease];
        cell.showsReorderControl = YES;
    }
    
    return (UITableViewCell*)[self.sectionContainer viewForControllerAtIndexPath:indexPath reusingView:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
/*
#ifdef DEBUG
    NSLog(@"heightForRowAtIndexPath: (%@ - %@) %f [%d %d]",[controller class],[controller name],size.height,indexPath.section,indexPath.row);
#endif
  */
    
    return size.height;
}


- (void)invalidateControllerAtIndexPath:(NSIndexPath*)indexPath{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    if(controller.contentViewCell){
        CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        return size.height;
    }
    return controller.estimatedSize.height;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidAppear)
        return;
    
    if(controller.state != CKViewControllerStateWillAppear){
        [controller viewWillAppear:NO];
    }
    if(controller.state != CKViewControllerStateDidAppear){
        [controller viewDidAppear:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    
    if(controller.contentViewCell != cell || controller.state == CKViewControllerStateDidDisappear)
        return;
    
    if(controller.state != CKViewControllerStateWillDisappear){
        [controller viewWillDisappear:NO];
    }
    if(controller.state != CKViewControllerStateDidDisappear){
        [controller viewDidDisappear:NO];
    }
}


#pragma mark Managing section headers

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.headerViewController)
        return nil;
    
    NSString* reuseIdentifier = [s.headerViewController reuseIdentifier];
    
#ifdef USING_UITableViewHeaderFooterView
    UITableViewHeaderFooterView* view = (UITableViewHeaderFooterView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
#else
    UIView* view = nil;
#endif
    
    if(!view){
#ifdef USING_UITableViewHeaderFooterView
        view = [[[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:reuseIdentifier]autorelease];
#else
        view = [[[UIView alloc]init]autorelease];
#endif
        view.flexibleSize = YES;
    }
    
    return [self.sectionContainer viewForController:s.headerViewController reusingView:view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.headerViewController)
        return UITableViewAutomaticDimension;
    
    CGSize size = [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)] ;
    return size.height;
}

#ifdef USING_UITableViewHeaderFooterView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.headerViewController)
        return UITableViewAutomaticDimension;
    
    if(s.headerViewController.contentViewCell){
        CGSize size = [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        return size.height;
    }
    return s.headerViewController.estimatedSize.height;
}

#endif

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    
    if(!s.headerViewController)
        return ;
    
    
    if(s.headerViewController.view != view || s.headerViewController.state == CKViewControllerStateDidAppear)
        return;
    
    if(s.headerViewController.state != CKViewControllerStateWillAppear){
        [s.headerViewController viewWillAppear:NO];
    }
    if(s.headerViewController.state != CKViewControllerStateDidAppear){
        [s.headerViewController viewDidAppear:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    
    if(!s.headerViewController)
        return ;
    
    if(s.headerViewController.view != view || s.headerViewController.state == CKViewControllerStateDidDisappear)
        return;
    
    if(s.headerViewController.state != CKViewControllerStateWillDisappear){
        [s.headerViewController viewWillDisappear:NO];
    }
    if(s.headerViewController.state != CKViewControllerStateDidDisappear){
        [s.headerViewController viewDidDisappear:NO];
    }
}


#pragma mark Managing section footers

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.footerViewController)
        return nil;
    
    NSString* reuseIdentifier = [s.footerViewController reuseIdentifier];

#ifdef USING_UITableViewHeaderFooterView
    UITableViewHeaderFooterView* view = (UITableViewHeaderFooterView*)[self.tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
#else
    UIView* view = nil;
#endif
    
    if(!view){
#ifdef USING_UITableViewHeaderFooterView
        view = [[[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:reuseIdentifier]autorelease];
#else
        view = [[[UIView alloc]init]autorelease];
#endif
        view.flexibleSize = YES;
    }
    
    return [self.sectionContainer viewForController:s.footerViewController reusingView:view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.footerViewController)
        return UITableViewAutomaticDimension;
    
    CGSize size = [s.footerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
    if(size.height < 0){
        int i =3;
    }
    return size.height;
}

#ifdef USING_UITableViewHeaderFooterView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.footerViewController)
        return UITableViewAutomaticDimension;
    
    if(s.footerViewController.contentViewCell){
        CGSize size = [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        if(size.height < 0){
            int i =3;
        }
        return size.height;
    }
    return s.footerViewController.estimatedSize.height;
}
#endif

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    
    if(!s.footerViewController)
        return ;
    
    if(s.footerViewController.view != view || s.footerViewController.state == CKViewControllerStateDidAppear)
        return ;
    
    if(s.footerViewController.state != CKViewControllerStateWillAppear){
        [s.footerViewController viewWillAppear:NO];
    }
    if(s.footerViewController.state != CKViewControllerStateDidAppear){
        [s.footerViewController viewDidAppear:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    
    if(!s.footerViewController)
        return ;
    
    if(s.footerViewController.view != view || s.footerViewController.state == CKViewControllerStateDidDisappear)
        return;
    
    if(s.footerViewController.state != CKViewControllerStateWillDisappear){
        [s.footerViewController viewWillDisappear:NO];
    }
    if(s.footerViewController.state != CKViewControllerStateDidDisappear){
        [s.footerViewController viewDidDisappear:NO];
    }
}

#pragma mark Managing selection and highlight


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    return controller.flags & CKViewControllerFlagsSelectable;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    [controller didHighlight];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    [controller didUnhighlight];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    BOOL bo = controller.flags & CKViewControllerFlagsSelectable;
    if(bo){
        return indexPath;
    }
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected addObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    [controller didSelect];
    
    if(!self.stickySelectionEnabled){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            //Cause didDeselectRowAtIndexPath is not called!
            NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
            [selected removeObject:indexPath];
            self.sectionContainer.selectedIndexPaths = selected;
            
            [controller didDeselect];
        });
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected removeObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
    
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    [controller didDeselect];
}

#pragma mark Managing Edition

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    CKAbstractSection* section = [self.sectionContainer sectionAtIndex:indexPath.section];
    
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    if(controller.flags & CKViewControllerFlagsRemovable)
        return YES;
    
    CKCollectionSection* collectionSection = [section isKindOfClass:[CKCollectionSection class]] ? (CKCollectionSection*)section : nil;
    if(collectionSection){
        NSRange range = [collectionSection rangeForCollectionControllers];
        if([collectionSection reorderingEnabled] && [[collectionSection collection]count] > 1 && indexPath.row >= range.location && indexPath.row < (range.location + range.length)){
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    CKAbstractSection* section = [self.sectionContainer sectionAtIndex:indexPath.section];
    
    CKCollectionSection* collectionSection = [section isKindOfClass:[CKCollectionSection class]] ? (CKCollectionSection*)section : nil;
    if(collectionSection){
        NSRange range = [collectionSection rangeForCollectionControllers];
        if([collectionSection reorderingEnabled] && [[collectionSection collection]count] > 1 && indexPath.row >= range.location && indexPath.row < (range.location + range.length)){
            return YES;
        }
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
        
        CKAbstractSection* section = [self.sectionContainer sectionAtIndex:indexPath.section];
        [self performBatchUpdates:^{
            [section sectionContainerDelegate:self willRemoveControllerAtIndex:indexPath.row];
        } completion:nil preventingUpdates:YES];
        
        [controller didRemove];
    }
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{ }

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{ }

- (NSIndexPath*)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    
    CKCollectionSection* section = (CKCollectionSection*)[self.sectionContainer sectionAtIndex:sourceIndexPath.section];
    NSRange rangeForCollectionControllers = [section rangeForCollectionControllers];
    
    if(sourceIndexPath.section == proposedDestinationIndexPath.section){
        if(proposedDestinationIndexPath.row <= rangeForCollectionControllers.location){
            return [NSIndexPath indexPathForRow:rangeForCollectionControllers.location inSection:sourceIndexPath.section];
        }else if (proposedDestinationIndexPath.row >= (rangeForCollectionControllers.location + rangeForCollectionControllers.length)){
            return [NSIndexPath indexPathForRow:(rangeForCollectionControllers.location + rangeForCollectionControllers.length - 1) inSection:sourceIndexPath.section];
        }
    }else if(proposedDestinationIndexPath.section < sourceIndexPath.section){
        return [NSIndexPath indexPathForRow:rangeForCollectionControllers.location inSection:sourceIndexPath.section];
    }else{
        return [NSIndexPath indexPathForRow:(rangeForCollectionControllers.location + rangeForCollectionControllers.length - 1) inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath{
    CKCollectionSection* section = (CKCollectionSection*)[self.sectionContainer sectionAtIndex:sourceIndexPath.section];
    
    [self performBatchUpdates:^{
        [section sectionContainerDelegate:self didMoveControllerAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (void)updateAppearanceOfVisibleControllers{
    NSArray* indexPaths = [self.tableView indexPathsForVisibleRows];
    NSArray* controllers = [self controllersAtIndexPaths:indexPaths];
    for(CKReusableViewController* controller in controllers){
        [controller setNeedsDisplay];
    }
}

#pragma mark Managing Scrolling

//TODO: Manage section fetchNextPage

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(object == self.tableView && [keyPath isEqualToString:@"contentSize"]){
        [self updateNumberOfPages];
    }
}

//Scroll callbacks : update self.currentPage
- (void)updateCurrentPage{
    CGFloat scrollPosition = self.tableView.contentOffset.y;
    CGFloat height = self.tableView.bounds.size.height;
    
    NSInteger intTmp = 0;
    if(height != 0){
        CGFloat tmp = scrollPosition / height ;
        intTmp = (NSInteger)tmp;
        CGFloat tmpdiff = tmp - intTmp;
        if(fabs(tmpdiff) > 0.5){
            ++intTmp;
        }
    }
    
    NSInteger page = intTmp;
    if(page < 0)
        page = 0;
    
    if(_currentPage != page){
        self.currentPage = page;
    }
}

- (void)updateNumberOfPages{
    CGFloat totalSize = self.tableView.contentSize.height;
    CGFloat height = self.tableView.bounds.size.height;
    int pages = (height != 0) ? totalSize / height : 0;
    if(pages < 0)
        pages = 0;
    
    if(_numberOfPages != pages){
        self.numberOfPages = pages;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.scrolling = YES;
    
    if(self.endEditingViewWhenScrolling){
        [[self.view superview] endEditing:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    [self updateCurrentPage];
    [self fetchMoreData];
    
    self.scrolling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateCurrentPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self updateCurrentPage];
    [self fetchMoreData];
    
    self.scrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPage];
    [self fetchMoreData];
    
    self.scrolling = NO;
}

- (void)fetchMoreData{
    NSMutableIndexSet* sectionsIndexes = [NSMutableIndexSet indexSet];
    NSMutableDictionary* lastRowForSections = [NSMutableDictionary dictionary];
    
    for (NSIndexPath *indexPath in self.tableView.indexPathsForVisibleRows) {
        NSInteger section = indexPath.section;
        [sectionsIndexes addIndex:indexPath.section];
        
        NSNumber* lastRow = [lastRowForSections objectForKey:@(section)];
        if(lastRow){
            if([lastRow integerValue] < indexPath.row){
                [lastRowForSections setObject:@(indexPath.row) forKey:@(section)];
            }
        }else{
            [lastRowForSections setObject:@(indexPath.row) forKey:@(section)];
        }
    }
    
    if(lastRowForSections.count == 0){
        for(CKSection* section in self.sectionContainer.sections){
            if([section isKindOfClass:[CKCollectionSection class]]){
                [sectionsIndexes addIndex:section.sectionIndex];
                [lastRowForSections setObject:@(0) forKey:@(section.sectionIndex)];
            }
        }
    }
    
    for(NSNumber* section in [lastRowForSections allKeys]){
        NSNumber* row = [lastRowForSections objectForKey:section];
        
        CKAbstractSection* abstractSection = [self sectionAtIndex:[section integerValue]];
        [abstractSection fetchNextPageFromIndex:[row integerValue]];
    }
}



#pragma mark Managing Keyboard Insets

- (void)registerForKeyboardNotifications
{
   if(!self.adjustInsetsOnKeyboardNotification)
        return;
    
    __unsafe_unretained CKTableViewController* bself = self;
    
    self.keyboardObservers = [NSMutableArray array];
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardWillShowNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
        [bself keyboardWasShown:note];
    }]];
    
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardWillHideNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
        [bself keyboardWillBeHidden:note];
    }]];
    
    
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:CKSheetWillShowNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                       [bself keyboardWasShown:note];
                                                                                   }]];
    
    [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:CKSheetWillHideNotification
                                                                                       object:nil
                                                                                        queue:[NSOperationQueue mainQueue]
                                                                                   usingBlock:^(NSNotification *note) {
                                                                                       [bself keyboardWillBeHidden:note];
                                                                                   }]];
}

- (void)unregisterForKeyboardNotifications
{
    for(id observer in self.keyboardObservers){
        [[NSNotificationCenter defaultCenter]removeObserver:observer];
    }
    self.keyboardObservers = nil;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = CGSizeZero;
    if([info objectForKey:CKSheetFrameEndUserInfoKey]){
        kbSize = [[info objectForKey:CKSheetFrameEndUserInfoKey] CGRectValue].size;
    }else{
        kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        self.lastPresentedKeyboardSize = kbSize;
        return; //Done by UITableViewController
    }
    
    CGFloat diff = (kbSize.height - self.lastPresentedKeyboardSize.height);
    if(diff == 0)
        return;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                  self.tableView.contentInset.left,
                                                  self.tableView.contentInset.bottom + diff,
                                                  self.tableView.contentInset.right);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    self.lastPresentedKeyboardSize = kbSize;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = CGSizeZero;
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    kbSize = self.lastPresentedKeyboardSize;
    if([info objectForKey:CKSheetFrameEndUserInfoKey]){
        animationCurve = (UIViewAnimationCurve)[[info objectForKey:CKSheetAnimationCurveUserInfoKey] integerValue];
        animationDuration = [[info objectForKey:CKSheetAnimationDurationUserInfoKey] floatValue];
    }else{
        self.lastPresentedKeyboardSize = CGSizeZero;
        return; //Done by UITableViewController
        
        // [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        //[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    }
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top,
                                                  self.tableView.contentInset.left,
                                                  self.tableView.contentInset.bottom - kbSize.height,
                                                  self.tableView.contentInset.right);
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
    
    self.lastPresentedKeyboardSize = CGSizeZero;
}



/* Forwarding calls to section container
 */

- (NSInteger)indexOfSection:(CKAbstractSection*)section{
    return [self.sectionContainer indexOfSection:section];
}

- (NSIndexSet*)indexesOfSections:(NSArray*)sections{
    return [self.sectionContainer indexesOfSections:sections];
}

- (id)sectionAtIndex:(NSInteger)index{
    return [self.sectionContainer sectionAtIndex:index];
}

- (NSArray*)sectionsAtIndexes:(NSIndexSet*)indexes{
    return [self.sectionContainer sectionsAtIndexes:indexes];
}

- (void)addSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer addSection:section animated:animated];
}

- (void)insertSection:(CKAbstractSection*)section atIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer insertSection:section atIndex:index animated:animated];
}

- (void)addSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer addSections:sections animated:animated];
}

- (void)insertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer insertSections:sections atIndexes:indexes animated:animated];
}

- (void)removeAllSectionsAnimated:(BOOL)animated{
    [self.sectionContainer removeAllSectionsAnimated:animated];
}

- (void)removeSection:(CKAbstractSection*)section animated:(BOOL)animated{
    [self.sectionContainer removeSection:section animated:animated];
}

- (void)removeSectionAtIndex:(NSInteger)index animated:(BOOL)animated{
    [self.sectionContainer removeSectionAtIndex:index animated:animated];
}

- (void)removeSections:(NSArray*)sections animated:(BOOL)animated{
    [self.sectionContainer removeSections:sections animated:animated];
}

- (void)removeSectionsAtIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    [self.sectionContainer removeSectionsAtIndexes:indexes animated:animated];
}

- (CKReusableViewController*)controllerAtIndexPath:(NSIndexPath*)indexPath{
    if(!indexPath)
        return nil;
    return [self.sectionContainer controllerAtIndexPath:indexPath];
}

- (NSArray*)controllersAtIndexPaths:(NSArray*)indexPaths{
    return [self.sectionContainer controllersAtIndexPaths:indexPaths];
}

- (NSIndexPath*)indexPathForController:(CKReusableViewController*)controller{
    return [self.sectionContainer indexPathForController:controller];
}

- (NSArray*)indexPathsForControllers:(NSArray*)controllers{
    return [self.sectionContainer indexPathsForControllers:controllers];
}

- (void)setSelectedIndexPaths:(NSArray*)selectedIndexPaths{
    self.sectionContainer.selectedIndexPaths = selectedIndexPaths;
}

- (NSArray*)selectedIndexPaths{
    return self.sectionContainer.selectedIndexPaths;
}


@end




@implementation CKReusableViewController(CKTableViewController)
@dynamic tableViewCell,tableView;

- (CKTableViewCell*)tableViewCell{
    if([self.contentViewCell isKindOfClass:[CKTableViewCell class]])
        return (CKTableViewCell*)self.contentViewCell;
    return nil;
}

- (UITableView*)tableView{
    if([self.contentView isKindOfClass:[UITableView class]])
        return (UITableView*)self.contentView;
    return nil;
}

#ifdef USING_UITableViewHeaderFooterView
- (UITableViewHeaderFooterView*)headerFooterView{
    if([self.contentViewCell isKindOfClass:[UITableViewHeaderFooterView class]])
        return (UITableViewHeaderFooterView*)self.contentViewCell;
    return nil;
}
#endif

@end


@implementation UITableView (AppCoreKit)
@dynamic isPreventingUpdates;

+ (void)load{
    CKSwizzleSelector([UITableView class], @selector(beginUpdates), @selector(AppCoreKit_beginUpdates));
    CKSwizzleSelector([UITableView class], @selector(endUpdates), @selector(AppCoreKit_endUpdates));
}

static char UITableViewPreventingUpdatesKey;

- (void)setPreventingUpdates:(BOOL)preventingUpdates{
    objc_setAssociatedObject(self, &UITableViewPreventingUpdatesKey, @(preventingUpdates), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isPreventingUpdates{
    id value = objc_getAssociatedObject(self, &UITableViewPreventingUpdatesKey);
    return value ? [value integerValue] : NO;
}

static char UITableViewNumberOfUpdatesKey;

- (void)setNumberOfUpdates:(NSInteger)updates{
    objc_setAssociatedObject(self, &UITableViewNumberOfUpdatesKey, @(updates), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)numberOfUpdates{
    id value = objc_getAssociatedObject(self, &UITableViewNumberOfUpdatesKey);
    return value ? [value integerValue] : NO;
}

- (void)beginPreventingUpdates{
    [self setPreventingUpdates : YES];
}

- (void)endPreventingUpdates{
    [self setPreventingUpdates : NO];
}

- (void)AppCoreKit_beginUpdates{
    if( self.isPreventingUpdates)
        return;
    
    if(self.numberOfUpdates == 0){
        //      NSLog(@"beginUpdates");
        [self AppCoreKit_beginUpdates];
    }
    self.numberOfUpdates++;
}

- (void)AppCoreKit_endUpdates{
    if( self.isPreventingUpdates)
        return;
    
    self.numberOfUpdates--;
    if(self.numberOfUpdates == 0){
        //       NSLog(@"endUpdates");
        [self AppCoreKit_endUpdates];
    }
}


@end
