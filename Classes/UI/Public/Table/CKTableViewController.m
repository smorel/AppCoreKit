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
#import "CKTableViewCellController.h"
#import "CKSheetController.h"
#import "CKTableViewControllerOld.h"


@interface CKTableViewController ()
@property(nonatomic,retain) NSMutableArray* keyboardObservers;
@property(nonatomic,assign) CGSize lastPresentedKeyboardSize;
@property (nonatomic,retain,readwrite) CKSectionContainer* sectionContainer;
@end

@implementation CKTableViewController

- (void)postInit{
    [super postInit];
    self.sectionContainer = [[CKSectionContainer alloc]initWithDelegate:self];
    self.adjustInsetsOnKeyboardNotification = YES;
    self.style = UITableViewStyleGrouped;
    self.endEditingViewWhenScrolling = YES;
}

- (void)dealloc{
    [self unregisterForKeyboardNotifications];
    [_sectionContainer release];
    [super dealloc];
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewStyle",
                                                 UITableViewStylePlain,
                                                 UITableViewStyleGrouped );
}

- (Class)tableViewClass{
    return [CKTableView class];
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

#pragma Managing Life Cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSMutableDictionary* stylesheet = [self controllerStyle];
    if([stylesheet containsObjectForKey:@"style"]){
        [NSValueTransformer transform:[stylesheet objectForKey:@"style"] inProperty:[CKProperty propertyWithObject:self keyPath:@"style"]];
    }
    
    self.tableView = [[[[self tableViewClass] alloc]initWithFrame:[UIScreen mainScreen].bounds style:self.style]autorelease];
    self.tableView.name = @"TableView";
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self presentsTableHeaderView];
    [self presentsTableFooterView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
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


- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    
    [self performBatchUpdates:^{
        [self.tableView insertSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self performBatchUpdates:^{
        [self.tableView deleteSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self performBatchUpdates:^{
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
        [self updateAppearanceOfVisibleControllers];
    } completion:nil preventingUpdates:YES];
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
 
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
        cell = [[CKTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.showsReorderControl = YES;
    }
    
    return (UITableViewCell*)[self.sectionContainer viewForControllerAtIndexPath:indexPath reusingView:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
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
    return controller.estimatedRowHeight;
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
        view = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:reuseIdentifier];
#else
        view = [[UIView alloc]init];
#endif
    }
    
    return [self.sectionContainer viewForController:s.headerViewController reusingView:view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.headerViewController)
        return UITableViewAutomaticDimension;
    
    return [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)].height ;
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
    return s.headerViewController.estimatedRowHeight;
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
        view = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:reuseIdentifier];
#else
        view = [[UIView alloc]init];
#endif
    }
    
    return [self.sectionContainer viewForController:s.footerViewController reusingView:view];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.footerViewController)
        return UITableViewAutomaticDimension;
    
    return [s.footerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)].height;
}

#ifdef USING_UITableViewHeaderFooterView

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self.sectionContainer sectionAtIndex:section];
    if(!s.footerViewController)
        return UITableViewAutomaticDimension;
    
    if(s.footerViewController.contentViewCell){
        CGSize size = [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
        return size.height;
    }
    return s.footerViewController.estimatedRowHeight;
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
    return controller.flags & CKItemViewFlagSelectable;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{ }

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{ }

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    BOOL bo = controller.flags & CKItemViewFlagSelectable;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //Cause didDeselectRowAtIndexPath is not called!
        NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
        [selected removeObject:indexPath];
        self.sectionContainer.selectedIndexPaths = selected;
    });
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    [selected removeObject:indexPath];
    self.sectionContainer.selectedIndexPaths = selected;
}

#pragma mark Managing Edition

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    CKAbstractSection* section = [self.sectionContainer sectionAtIndex:indexPath.section];
    
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:indexPath];
    return (controller.flags & CKViewControllerFlagsRemovable)
        || ([section isKindOfClass:[CKCollectionSection class]] && [(CKCollectionSection*)section reorderingEnabled] == YES && [[(CKCollectionSection*)section collection]count] > 1);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    CKAbstractSection* section = [self.sectionContainer sectionAtIndex:indexPath.section];
    return ([section isKindOfClass:[CKCollectionSection class]] && [(CKCollectionSection*)section reorderingEnabled] == YES && [[(CKCollectionSection*)section collection]count] > 1);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        CKAbstractSection* section = [self.sectionContainer sectionAtIndex:indexPath.section];
        [self performBatchUpdates:^{
            [section sectionContainerDelegate:self willRemoveControllerAtIndex:indexPath.row];
        } completion:nil preventingUpdates:YES];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.endEditingViewWhenScrolling){
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
    }
}


#pragma mark Managing Keyboard Insets

- (void)registerForKeyboardNotifications
{
   if(!self.adjustInsetsOnKeyboardNotification)
        return;
    
    __unsafe_unretained CKTableViewController* bself = self;
    
    self.keyboardObservers = [NSMutableArray array];
   /* [self.keyboardObservers addObject:[[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardWillShowNotification
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
    */
    
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
        //kbSize = [[info objectForKey:CKSheetFrameEndUserInfoKey] CGRectValue].size;
        animationCurve = (UIViewAnimationCurve)[[info objectForKey:CKSheetAnimationCurveUserInfoKey] integerValue];
        animationDuration = [[info objectForKey:CKSheetAnimationDurationUserInfoKey] floatValue];
    }else{
        //kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
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
@dynamic tableViewCell;

- (CKTableViewCell*)tableViewCell{
    if([self.contentViewCell isKindOfClass:[CKTableViewCell class]])
        return (CKTableViewCell*)self.contentViewCell;
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
