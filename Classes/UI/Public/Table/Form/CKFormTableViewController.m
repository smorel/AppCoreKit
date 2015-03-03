//
//  CKFormTableViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKFormTableViewController.h"
#import "CKFormTableViewController_private.h"
#import "CKFormSectionBase_private.h"
#import "CKFormBindedCollectionSection_private.h"
#import "CKObjectController.h"
#import "CKCollectionCellControllerFactory.h"
#import "NSObject+Invocation.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "CKTableViewCellController+Style.h"
#import "CKPropertyTableViewCellController.h"

#import "CKDebug.h"

//private interfaces

@interface CKCollectionViewController()
@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;
@end

@interface CKCollectionViewController(CKCollectionCellControllerManagement)
- (void) insertItemViewControllersSectionAtIndex:(NSInteger)index;
@end

@interface CKCollectionCellControllerFactory ()
@property (nonatomic, assign) id objectController;
- (CKCollectionCellControllerFactoryItem*)factoryItemForObject:(id)object atIndexPath:(NSIndexPath*)indexPath;
- (CKItemViewFlags)flagsForControllerIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (CGSize)sizeForControllerAtIndexPath:(NSIndexPath*)indexPath params:(NSMutableDictionary*)params;
- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController *)collectionViewController;
@end


//CKFormObjectController

@interface CKFormObjectController : NSObject<CKObjectController>{
	id _delegate;
	CKFormTableViewController* _parentController;
}
@property (nonatomic, assign) id delegate;
@property (nonatomic,assign) CKFormTableViewController* parentController;
- (id)initWithParentController:(CKFormTableViewController*)controller;
@end

@implementation CKFormObjectController
@synthesize delegate = _delegate;
@synthesize parentController = _parentController;

- (id)initWithParentController:(CKFormTableViewController*)controller{
	if (self = [super init]) {
      self.parentController = controller;  
    }
	return self;
}

- (NSUInteger)numberOfSections{
	NSUInteger count = [self.parentController numberOfVisibleSections];
	return count;
}

- (NSUInteger)numberOfObjectsForSection:(NSInteger)section{
	CKFormSectionBase* formSection = (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	NSUInteger count = formSection.collapsed ? 0 : [formSection numberOfObjects];
	return count;
}

- (NSString*)headerTitleForSection:(NSInteger)section{
	NSInteger sectionCount = [self numberOfSections];
	if([_parentController autoHideSectionHeaders] && sectionCount <= 1)
		return nil;
	
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	return formSection.headerTitle;
}

- (UIView*)headerViewForSection:(NSInteger)section{
	NSInteger sectionCount = [self numberOfSections];
	if([_parentController autoHideSectionHeaders] && sectionCount <= 1)
		 return nil;
	
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	return formSection.headerView;
}

- (NSString*)footerTitleForSection:(NSInteger)section{
	NSInteger sectionCount = [self numberOfSections];
	if([_parentController autoHideSectionHeaders] && sectionCount <= 1)
		return nil;
	
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	return formSection.footerTitle;
}

- (UIView*)footerViewForSection:(NSInteger)section{
	NSInteger sectionCount = [self numberOfSections];
	if([_parentController autoHideSectionHeaders] && sectionCount <= 1)
        return nil;
	
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	return formSection.footerView;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:indexPath.section];
	id object = [formSection objectAtIndex:indexPath.row];
	return object;
}

- (void)setDelegate:(id)theDelegate{
	_delegate = theDelegate;
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath{
	CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:indexPath.section];
	return [formSection removeObjectAtIndex:indexPath.row];
}

- (void)fetchRange:(NSRange)range forSection:(NSInteger)section{
	CKFormSectionBase* formSection = (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:section];
	[formSection fetchRange:range];
}

- (void)lock{
	for(int i=0;i<[self numberOfSections];++i){
		CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:i];
		[formSection lock];
	}
}

- (void)unlock{
	for(int i=0;i<[self numberOfSections];++i){
		CKFormSectionBase* formSection =  (CKFormSectionBase*)[self.parentController visibleSectionAtIndex:i];
		[formSection unlock];
	}
}

@end

//CKFormObjectControllerFactory

@interface CKFormObjectControllerFactory : CKCollectionCellControllerFactory{
}
@end

@implementation CKFormObjectControllerFactory

- (id)controllerForObject:(id)object atIndexPath:(NSIndexPath*)indexPath collectionViewController:(CKCollectionViewController *)collectionViewController{
    CKFormObjectController* formObjectController = (CKFormObjectController*)self.objectController;
	CKFormTableViewController* formController = (CKFormTableViewController*)formObjectController.parentController;
	CKFormSectionBase* formSection = (CKFormSectionBase*)[formController visibleSectionAtIndex:indexPath.section];
	return [formSection controllerForObject:object atIndex:indexPath.row];
}

@end


//CKFormTableViewController

@implementation CKFormTableViewController{
	NSMutableArray* _sections;
	BOOL _autoHideSections;
	BOOL _autoHideSectionHeaders;
	BOOL reloading;
    BOOL _validationEnabled;
}

@synthesize sections = _sections;
@synthesize autoHideSections = _autoHideSections;
@synthesize autoHideSectionHeaders = _autoHideSectionHeaders;
@synthesize reloading;
@synthesize validationEnabled = _validationEnabled;
@dynamic tableViewHasBeenReloaded;

- (void)postInit{
	[super postInit];
	self.objectController = [[[CKFormObjectController alloc]initWithParentController:self]autorelease];
	self.controllerFactory = [[[CKFormObjectControllerFactory alloc]init]autorelease];
	self.sections = [NSMutableArray array];
	_autoHideSections = NO;
	_autoHideSectionHeaders = NO;
    _validationEnabled = NO;
    self.style = UITableViewStyleGrouped;
    self.scrollingPolicy = CKTableCollectionViewControllerScrollingPolicyResignResponder;
}

- (void)setValidationEnabled:(BOOL)validationEnabled{
    [self.tableView beginUpdates];
    [self willChangeValueForKey:@"validationEnabled"];
    _validationEnabled = validationEnabled;
    [self didChangeValueForKey:@"validationEnabled"];
    [self.tableView endUpdates];
}

- (void)dealloc{
    for(CKFormSectionBase* section in _sections){
		section.parentController = nil;
    }
    
	[_sections release];
	_sections = nil;
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
	self.reloading = YES;
	for(CKFormSectionBase* section in _sections){
		[section start];
		if(self.autoHideSections && [section isKindOfClass:[CKFormBindedCollectionSection class]]){
			section.hidden = ([section numberOfObjects] <= 0);
		}
	 }
	
	[super viewWillAppear:animated];
	self.reloading = NO;
}


- (void)clear{
	self.reloading = YES;
	self.sections = [NSMutableArray array];
	[super reload];
}

- (void)reload{
	self.reloading = YES;
	if(self.state & CKViewControllerStateDidAppear){
		for(CKFormSectionBase* section in _sections){
			[section start];
			
			if([section isKindOfClass:[CKFormBindedCollectionSection class]]){
				section.hidden = (self.autoHideSections && [section numberOfObjects] <= 0);
				if(section.hidden){
					CKFormBindedCollectionSection* collecSection = (CKFormBindedCollectionSection*)section;
                    if(self.autoFetchCollections || [collecSection.objectController.collection count] <= 0){
                        [collecSection.objectController.collection fetchRange:NSMakeRange(0, self.minimumNumberOfSupplementaryObjectsInSections)];
                    }
				}
			}
		}
	}
	
	self.reloading = NO;
	[super reload];
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	for(CKFormSectionBase* section in _sections){
		[section stop];
	}
}


- (id)initWithSections:(NSArray*)theSections{
	self = [super init];
	self.sections = [NSMutableArray arrayWithArray:theSections];
	for(CKFormSectionBase* section in theSections){
		section.parentController = self;
		if(section.hidden == YES){
			if([section isKindOfClass:[CKFormBindedCollectionSection class]]){
				CKFormBindedCollectionSection* collecSection = (CKFormBindedCollectionSection*)section;
                if(self.autoFetchCollections || [collecSection.objectController.collection count] <= 0){
                    [collecSection.objectController.collection fetchRange:NSMakeRange(0, self.minimumNumberOfSupplementaryObjectsInSections)];
                }
			}
		}
	}
	return self;
}

- (NSArray*)addSections:(NSArray *)sections{
	[_sections addObjectsFromArray:sections];
    
    NSMutableIndexSet* indexSet = nil;
    for(CKFormSectionBase* section in sections){
        section.parentController = self;
        [section start];
        if(!section.hidden){
            if(indexSet == nil){
                indexSet = [NSMutableIndexSet indexSet];
            }
            NSInteger index = section.sectionVisibleIndex;
            [indexSet addIndex:index];
        }
        if(self.isViewDisplayed){
            if([section isKindOfClass:[CKFormBindedCollectionSection class]]){
                dispatch_async(dispatch_get_main_queue(), ^{//Support for sections with pre-loaded content 
                    CKFormBindedCollectionSection* collecSection = (CKFormBindedCollectionSection*)section;
                    if(self.autoFetchCollections || [collecSection.objectController.collection count] <= 0){
                        [collecSection.objectController.collection fetchRange:NSMakeRange(0, self.minimumNumberOfSupplementaryObjectsInSections)];
                    }
                });
                
            }
        }
    }
    
    if(indexSet && self.isViewDisplayed){
        if((self.state & CKViewControllerStateDidAppear)){
            UITableViewRowAnimation anim = self.rowInsertAnimation;
            
            NSInteger currentIndex = [indexSet firstIndex];
            while (currentIndex != NSNotFound) {
                [self insertItemViewControllersSectionAtIndex:currentIndex];
                currentIndex = [indexSet indexGreaterThanIndex: currentIndex];
            }
            
            [self.tableView beginUpdates];
            [self.tableView insertSections:indexSet withRowAnimation:anim];
            [self.tableView endUpdates];
        }
        else{
            //Calls super explicitely here as we do not want initializations done in form.
            [super reload];
        }
    }
    else if(indexSet && !self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
    }
    
    return sections;
}

- (CKFormSectionBase *)insertSection:(CKFormSectionBase*)section atIndex:(NSInteger)index{
	section.parentController = self;
    [section start];
	[_sections insertObject:section atIndex:index];
    
    if(section.hidden == NO){
        [self objectController:self.objectController insertSectionAtIndex:section.sectionVisibleIndex];
    }
    
	return section;
}

- (CKFormSectionBase *)removeSectionAtIndex:(NSInteger)index{
    CKFormSectionBase* section = (CKFormSectionBase*)[_sections objectAtIndex:index];
    [section stop];
    NSInteger visibleIndex = section.sectionVisibleIndex;
    
    [section retain];
    [_sections removeObjectAtIndex:index];
    
    if(section.hidden == NO && visibleIndex >= 0){
        [self objectController:self.objectController removeSectionAtIndex:visibleIndex];
    }
    
    section.parentController = nil;
    
	return [section autorelease];
}

- (CKFormSectionBase*)sectionAtIndex:(NSUInteger)index{
	if(index < [_sections count]){
		CKFormSectionBase* section = [_sections objectAtIndex:index];
		return section;
	}
	return nil;
}

- (NSInteger)indexOfSection:(CKFormSectionBase *)section{
	return [_sections indexOfObject:section];
}


- (NSUInteger)numberOfVisibleSections{
	NSInteger count = 0;
	for(CKFormSectionBase* section in _sections){
		if(!section.hidden){
			++count;
		}
	}
	return count;
}

- (CKFormSectionBase*)visibleSectionAtIndex:(NSInteger)index{
	NSInteger count = 0;
	for(CKFormSectionBase* section in _sections){
		if(!section.hidden){
			if(index == count){
				return section;
			}
			++count;
		}
	}	
	return nil;
}

- (NSInteger)indexOfVisibleSection:(CKFormSectionBase*)thesection{
	NSInteger count = 0;
	for(CKFormSectionBase* section in _sections){
		if(!section.hidden){
			if(section == thesection){
				return count;
			}
			++count;
		}
	}	
	return -1;
}

- (void)setSections:(NSArray*)sections hidden:(BOOL)hidden{
    [self objectControllerDidBeginUpdating:self.objectController];
    if(hidden){
        NSMutableDictionary* sectionsByIndex = [NSMutableDictionary dictionary];
        for(CKFormSectionBase* section in sections){
            if(hidden && section.hidden == NO){
                NSInteger index = section.sectionVisibleIndex;
                [sectionsByIndex setObject:section forKey:[NSNumber numberWithInteger:index]];
            }
        }
        
        //Sort by bigest number
        NSArray* sortedIndexes = [[sectionsByIndex allKeys]sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if([obj1 integerValue] > [obj2 integerValue]){
                return NSOrderedAscending;
            }
            else if([obj1 integerValue] ==  [obj2 integerValue]){
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }];
        
        for(NSNumber* indexNb in sortedIndexes)
        {
            NSInteger index = [indexNb integerValue];
            [self objectController:self.objectController removeSectionAtIndex:index];
        }
        
        for(CKFormSectionBase* section in sections){
            section.hidden = YES;
        }
    }
    else{ 
        NSMutableDictionary* sectionsByIndex = [NSMutableDictionary dictionary];
        for(CKFormSectionBase* section in sections){
            if(!hidden && section.hidden == YES){
                section.hidden = NO;
                [sectionsByIndex setObject:section forKey:[NSNumber numberWithInteger:section.sectionVisibleIndex]];
            }
        }
        
        //Sort by smallest number
        NSArray* sortedIndexes = [[sectionsByIndex allKeys]sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if([obj1 integerValue] < [obj2 integerValue]){
                return NSOrderedAscending;
            }
            else if([obj1 integerValue] ==  [obj2 integerValue]){
                return NSOrderedSame;
            }
            return NSOrderedDescending;
        }];

        
        for(NSNumber* indexNb in sortedIndexes){
            NSInteger index = [indexNb integerValue];
            [self objectController:self.objectController insertSectionAtIndex:index];
        }
    }
    [self objectControllerDidEndUpdating:self.objectController];
}


- (NSSet*)allEditingProperties{
    NSMutableSet* set = [NSMutableSet set];
    for(int section=0; section < [self numberOfSections];++section){
        NSInteger rowCount = [self numberOfObjectsForSection:section];
        for(int row=0;row < rowCount;++row){
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            CKCollectionCellController* cellController = [self controllerAtIndexPath:indexPath];
            if([cellController isKindOfClass:[CKPropertyTableViewCellController class]]){
                CKPropertyTableViewCellController* propertyCell = (CKPropertyTableViewCellController*)cellController;
                [set addObject:propertyCell.value];
            }
        }
    }
    return set;
}

@end