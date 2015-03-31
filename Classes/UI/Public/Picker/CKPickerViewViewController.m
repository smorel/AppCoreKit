//
//  CKPickerViewViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-17.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPickerViewViewController.h"
#import "UIView+Name.h"
#import "UIView+AutoresizingMasks.h"
#import "UIView+Positioning.h"

@interface CKPickerViewViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,retain,readwrite) UIPickerView* pickerView;
@property (nonatomic,retain,readwrite) CKSectionContainer* sectionContainer;
@end

@implementation CKPickerViewViewController

- (void)dealloc{
    [_pickerView release];
    [_sectionContainer release];
    [super dealloc];
}

- (void)postInit{
    [super postInit];
    self.sectionContainer = [[CKSectionContainer alloc]initWithDelegate:self];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.pickerView = [[[UIPickerView alloc]init]autorelease];
    CGSize size = [self.pickerView sizeThatFits:self.view.bounds.size];
    self.pickerView.frame = CGRectMake((self.view.width/2)-(size.width/2),(self.view.height/2) - (size.height /2),size.width,size.height);
    self.pickerView.name = @"PickerView";
    self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleAllMargins;
    
    [self.view addSubview:self.pickerView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.sectionContainer handleViewWillAppearAnimated:animated];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pickerView reloadAllComponents];
    
    for(NSIndexPath* indexPath in self.sectionContainer.selectedIndexPaths){
        [self.pickerView selectRow:indexPath.row inComponent:indexPath.section animated:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.sectionContainer handleViewDidAppearAnimated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.sectionContainer handleViewWillDisappearAnimated:animated];
    
    self.pickerView.delegate = nil;
    self.pickerView.dataSource = nil;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.sectionContainer handleViewDidDisappearAnimated:animated];
}

- (void)reloadComponentsMatchingIndexPaths:(NSArray*)indexPaths{
    NSMutableIndexSet* sections = [NSMutableIndexSet indexSet];
    for(NSIndexPath* indexPath in indexPaths){
        [sections addIndex:indexPath.section];
    }
    
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self.pickerView reloadComponent:idx];
    }];
}


- (void)didInsertSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    sectionUpdate();
    [self.pickerView reloadAllComponents];
}

- (void)didRemoveSections:(NSArray*)sections atIndexes:(NSIndexSet*)indexes animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    sectionUpdate();
    [self.pickerView reloadAllComponents];
}

- (void)didInsertControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    sectionUpdate();
    [self reloadComponentsMatchingIndexPaths:indexPaths];
}

- (void)didRemoveControllers:(NSArray*)controllers atIndexPaths:(NSArray*)indexPaths animated:(BOOL)animated sectionUpdate:(void (^)())sectionUpdate{
    sectionUpdate();
    [self reloadComponentsMatchingIndexPaths:indexPaths];
}

- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion{
    if(updates){ updates(); }
    if(completion){ completion(YES); }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.sectionContainer.sections.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component >= self.sectionContainer.sections.count)
        return 0;
    
    CKAbstractSection* section = [self.sectionContainer sectionAtIndex:component];
    return section.controllers.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if(component >= self.sectionContainer.sections.count)
        return 0.0f;
    
    return self.sectionContainer.sections.count > 0 ? self.view.width / self.sectionContainer.sections.count : self.view.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    if(component >= self.sectionContainer.sections.count)
        return 0.0f;
    
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:component]];
    CGFloat width = [self pickerView:pickerView widthForComponent:component];
    
    CGSize size = [controller preferredSizeConstraintToSize:CGSizeMake(width,MAXFLOAT)];
    return size.height;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    return [self.sectionContainer viewForControllerAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component] reusingView:view];
}


- (CGSize)contentSizeForViewInPopover{
    return CGSizeMake(self.pickerView.width,self.pickerView.height);
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSMutableArray* indexPaths = [NSMutableArray arrayWithArray:self.sectionContainer.selectedIndexPaths];
    
    NSInteger index = 0;
    for(NSIndexPath* ip in self.sectionContainer.selectedIndexPaths){
        if(ip.section == component){
            [indexPaths removeObjectAtIndex:index];
            break;
        }
        ++index;
    }
    
    [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:component]];
    
    self.sectionContainer.selectedIndexPaths = indexPaths;
    
    CKReusableViewController* controller = [self.sectionContainer controllerAtIndexPath:[NSIndexPath indexPathForRow:row inSection:component]];
    [controller didSelect];
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
