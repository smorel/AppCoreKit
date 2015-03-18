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


@interface CKTableViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain,readwrite) UITableView* tableView;
@end

@implementation CKTableViewController

- (void)postInit{
    [super postInit];
    self.style = UITableViewStyleGrouped;
    self.endEditingViewWhenScrolling = YES;
}

- (void)dealloc{
    [_tableView release];
    [super dealloc];
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewStyle",
                                                 UITableViewStylePlain,
                                                 UITableViewStyleGrouped );
}

- (Class)tableViewClass{
    return [UITableView class];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSMutableDictionary* stylesheet = [self controllerStyle];
    if([stylesheet containsObjectForKey:@"style"]){
        [NSValueTransformer transform:[stylesheet objectForKey:@"style"] inProperty:[CKProperty propertyWithObject:self keyPath:@"style"]];
    }
    
    self.tableView = [[[[self tableViewClass] alloc]initWithFrame:self.view.bounds style:self.style]autorelease];
    self.tableView.name = @"TableView";
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleSize;
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    //for(NSIndexPath* indexPath in self.selectedIndexPaths){
    //    [self.pickerView selectRow:indexPath.row inComponent:indexPath.section animated:NO];
    //}
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion{
    [self.tableView beginUpdates];
    if(updates){
        updates();
    }
    [self.tableView endUpdates];
    
    if(completion){
        completion(YES);
    }
}

#pragma mark CKSectionedViewController protocol


- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView insertSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView deleteSections:indexes withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated{
    if(self.state != CKViewControllerStateDidAppear) return;
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone) ];
}

- (UIView*)contentView{
    return self.tableView;
}

- (void)scrollToControllerAtIndexPath:(NSIndexPath*)indexpath animated:(BOOL)animated{
    [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
}

#pragma mark Managing Content

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    return s.controllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    NSString* reuseIdentifier = [controller reuseIdentifier];
    
    BOOL needsToCallViewDidLoad = NO;
    
    CKTableViewCell* cell = (CKTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell){
        cell = [[CKTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        needsToCallViewDidLoad = YES;
    }
    
    
    [self viewForControllerAtIndexPath:indexPath reusingView:cell];
    if(needsToCallViewDidLoad){
        [controller viewDidLoad];
    }
    
    [controller viewWillAppear:NO];
    [controller viewDidAppear:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)];
    return size.height;
}


- (void)invalidateSizeForControllerAtIndexPath:(NSIndexPath*)indexPath{
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

/*
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
*/

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    
    [controller viewWillDisappear:NO];
    [controller viewDidDisappear:NO];
}


#pragma mark Managing section headers

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.headerViewController)
        return nil;
    
    UIView* v = s.headerViewController.view;
    
    [s.headerViewController viewWillAppear:NO];
    [s.headerViewController viewDidAppear:NO];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.headerViewController)
        return 0;
    
    return [s.headerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)].height;
}

/*
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    
}
*/

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.headerViewController)
        return ;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.headerViewController)
        return ;
    
    [s.headerViewController viewWillDisappear:NO];
    [s.headerViewController viewDidDisappear:NO];
}


#pragma mark Managing section footers

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.footerViewController)
        return nil;
    
    UIView* v = s.footerViewController.view;
    
    [s.footerViewController viewWillAppear:NO];
    [s.footerViewController viewDidAppear:NO];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    if(!s.footerViewController)
        return 0;
    
    return [s.footerViewController preferredSizeConstraintToSize:CGSizeMake(self.tableView.width,MAXFLOAT)].height;
}

/*
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section{
    
}
*/

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.footerViewController)
        return ;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section{
    CKAbstractSection* s = [self sectionAtIndex:section];
    
    if(!s.footerViewController)
        return ;
    
    [s.footerViewController viewWillDisappear:NO];
    [s.footerViewController viewDidDisappear:NO];
}

#pragma mark Managing selection and highlight


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES; //TODO
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
     //TODO
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
     //TODO
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
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
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.selectedIndexPaths];
    [selected addObject:indexPath];
    self.selectedIndexPaths = selected;
    
    CKCollectionCellContentViewController* controller = [self controllerAtIndexPath:indexPath];
    [controller didSelect];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //Cause didDeselectRowAtIndexPath is not called!
        NSMutableArray* selected = [NSMutableArray arrayWithArray:self.selectedIndexPaths];
        [selected removeObject:indexPath];
        self.selectedIndexPaths = selected;
    });
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray* selected = [NSMutableArray arrayWithArray:self.selectedIndexPaths];
    [selected removeObject:indexPath];
    self.selectedIndexPaths = selected;
}

#pragma mark Managing Edition

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;//TODO
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;//TODO
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    //TODO
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.endEditingViewWhenScrolling){
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
    }
}

@end




@implementation CKCollectionCellContentViewController(CKTableViewController)
@dynamic tableViewCell;

- (CKTableViewCell*)tableViewCell{
    if([self.contentViewCell isKindOfClass:[CKTableViewCell class]])
        return (CKTableViewCell*)self.contentViewCell;
    return nil;
}

@end
