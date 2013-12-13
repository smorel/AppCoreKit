//
//  CKTableCollectionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright Wherecloud 2011. All rights reserved.
//

#import "CKTableCollectionViewController.h"
#import "CKTableViewCellController+DynamicLayout.h"
#import "CKTableViewCellController+DynamicLayout_Private.h"
#import "NSDate+Conversions.h"
#import "NSDate+Calculations.h"
#import <objc/runtime.h>
#import "UIKeyboard+Information.h"
#import <QuartzCore/QuartzCore.h>
#import "CKVersion.h"
#import "CKCollectionController.h"
#import "NSObject+Bindings.h"
#include "CKSheetController.h"
#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "UIViewController+Style.h"
#import "CKLocalization.h"
#import "NSObject+Invocation.h"
#import "CKRuntime.h"
#import "UIView+Positioning.h"


@interface CKCollectionViewController()

@property (nonatomic, retain) NSMutableDictionary* viewsToControllers;
@property (nonatomic, retain) NSMutableDictionary* viewsToIndexPath;
@property (nonatomic, retain) NSMutableDictionary* indexPathToViews;
@property (nonatomic, retain) NSMutableArray* weakViews;
@property (nonatomic, retain) NSMutableArray* sectionsToControllers;

@property (nonatomic, retain) id objectController;
@property (nonatomic, retain) CKCollectionCellControllerFactory* controllerFactory;

- (void)updateVisibleViewsIndexPath;
- (void)updateVisibleViewsRotation;
- (void)updateViewsVisibility:(BOOL)visible;

@end



@interface CKTableViewController ()

- (void)sizeToFit;

- (void)adjustTableViewInsets;

@end

/********************************* CKTableCollectionViewController  *********************************
 */

@interface CKTableCollectionViewController ()
@property (nonatomic, retain) NSIndexPath* indexPathToReachAfterRotation;
@property (nonatomic, retain) NSIndexPath* selectedIndexPath;
@property (nonatomic, assign, readwrite) int currentPage;
@property (nonatomic, assign, readwrite) int numberOfPages;
@property (nonatomic, retain, readwrite) UISearchBar* searchBar;
@property (nonatomic, retain, readwrite) UISegmentedControl* segmentedControl;
@property (nonatomic, assign) BOOL tableViewHasBeenReloaded;
@property (nonatomic, retain) NSString *bindingContextForTableView;
@property (nonatomic, assign, readwrite) BOOL scrolling;

- (void)updateNumberOfPages;
- (void)adjustView;
- (void)adjustTableView;
- (void)tableViewFrameChanged:(id)value;

- (void)createsAndDisplayEditableButtonsWithType:(CKTableCollectionViewControllerEditingType)type animated:(BOOL)animated;

@end



@implementation CKTableCollectionViewController{
	CKTableViewOrientation _orientation;
	BOOL _resizeOnKeyboardNotification;
	
	int _currentPage;
	int _numberOfPages;
	
	BOOL _scrolling;
    CKTableCollectionViewControllerScrollingPolicy _scrollingPolicy;
    
    CKTableCollectionViewControllerEditingType _editableType;
    
	UITableViewRowAnimation _rowInsertAnimation;
	UITableViewRowAnimation _rowRemoveAnimation;
	
	//for editable tables
	UIBarButtonItem *editButton;
	UIBarButtonItem *doneButton;
	
	//internal
	NSIndexPath* _indexPathToReachAfterRotation;
	
	//search
	BOOL _searchEnabled;
	UISearchBar* _searchBar;
	CGFloat _liveSearchDelay;
	UISegmentedControl* _segmentedControl;
	NSDictionary* _searchScopeDefinition;//dico of with [object:CKCallback key:localized label or uiimage]
	id _defaultSearchScope;
	
    int _modalViewCount;
    
    
    id _storedTableDelegate;
    id _storedTableDataSource;
    
    BOOL _registeredToContentSize;
}

@synthesize currentPage = _currentPage;
@synthesize numberOfPages = _numberOfPages;
@synthesize orientation = _orientation;
@synthesize resizeOnKeyboardNotification = _resizeOnKeyboardNotification;
@synthesize scrolling = _scrolling;
@synthesize indexPathToReachAfterRotation = _indexPathToReachAfterRotation;
@synthesize rowInsertAnimation = _rowInsertAnimation;
@synthesize rowRemoveAnimation = _rowRemoveAnimation;
@synthesize searchEnabled = _searchEnabled;
@synthesize searchBar = _searchBar;
@synthesize liveSearchDelay = _liveSearchDelay;
@synthesize segmentedControl = _segmentedControl;
@synthesize searchScopeDefinition = _searchScopeDefinition;
@synthesize defaultSearchScope = _defaultSearchScope;
@synthesize scrollingPolicy = _scrollingPolicy;
@synthesize editableType = _editableType;
@synthesize searchBlock = _searchBlock;
@synthesize snapPolicy = _snapPolicy;
@synthesize bindingContextForTableView = _bindingContextForTableView;

@synthesize editButton;
@synthesize doneButton;
@dynamic selectedIndexPath;
@dynamic tableViewHasBeenReloaded;

@synthesize rowInsertAnimationBlock = _rowInsertAnimationBlock;
@synthesize rowRemoveAnimationBlock = _rowRemoveAnimationBlock;
@synthesize sectionInsertAnimationBlock = _sectionInsertAnimationBlock;
@synthesize sectionRemoveAnimationBlock = _sectionRemoveAnimationBlock;

- (void)rowInsertAnimationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewRowAnimation",
                                                 UITableViewRowAnimationFade,
                                                 UITableViewRowAnimationRight,
                                                 UITableViewRowAnimationLeft,
                                                 UITableViewRowAnimationTop,
                                                 UITableViewRowAnimationBottom,
                                                 UITableViewRowAnimationNone,     
                                                 UITableViewRowAnimationMiddle,          
                                                 UITableViewRowAnimationAutomatic);
}

- (void)rowRemoveAnimationExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"UITableViewRowAnimation",
                                                 UITableViewRowAnimationFade,
                                                 UITableViewRowAnimationRight,
                                                 UITableViewRowAnimationLeft,
                                                 UITableViewRowAnimationTop,
                                                 UITableViewRowAnimationBottom,
                                                 UITableViewRowAnimationNone,     
                                                 UITableViewRowAnimationMiddle,          
                                                 UITableViewRowAnimationAutomatic);
}

#pragma mark Initialization

- (void)postInit{
	[super postInit];
	_rowInsertAnimation = UITableViewRowAnimationFade;
	_rowRemoveAnimation = UITableViewRowAnimationFade;
    
    self.rowInsertAnimationBlock = ^(CKTableCollectionViewController* controller, NSArray* objects, NSArray* indexPaths){
        return (controller.isViewDisplayed) ?  controller.rowInsertAnimation : UITableViewRowAnimationNone;
    };
    
    self.rowRemoveAnimationBlock = ^(CKTableCollectionViewController* controller, NSArray* objects, NSArray* indexPaths){
        return (controller.isViewDisplayed) ?  controller.rowRemoveAnimation : UITableViewRowAnimationNone;
    };
    
    self.sectionInsertAnimationBlock = ^(CKTableCollectionViewController* controller, NSInteger index){
        return (controller.isViewDisplayed) ?  controller.rowInsertAnimation : UITableViewRowAnimationNone;
    };
    
    self.sectionRemoveAnimationBlock = ^(CKTableCollectionViewController* controller, NSInteger index){
        return (controller.isViewDisplayed) ?  controller.rowRemoveAnimation : UITableViewRowAnimationNone;
    };
    
	_orientation = CKTableViewOrientationPortrait;
	_resizeOnKeyboardNotification = YES;
	_currentPage = 0;
	_numberOfPages = 0;
	_scrolling = NO;
	_editableType = CKTableCollectionViewControllerEditingTypeNone;
	_searchEnabled = NO;
	_liveSearchDelay = 0.5;
    _scrollingPolicy = CKTableCollectionViewControllerScrollingPolicyNone;
    _snapPolicy = CKTableCollectionViewControllerSnappingPolicyNone;
    _registeredToContentSize = NO;
    
    self.bindingContextForTableView = [NSString stringWithFormat:@"TableVisibility_<%p>",self];
}

- (void)dealloc {
    if(_registeredToContentSize){
        [self.tableView removeObserver:self forKeyPath:@"contentSize"];
        _registeredToContentSize = NO;
    }
    
	[NSObject removeAllBindingsForContext:_bindingContextForTableView];
    
	[_bindingContextForTableView release];
	_bindingContextForTableView = nil;
	[_indexPathToReachAfterRotation release];
	_indexPathToReachAfterRotation = nil;
	[editButton release];
	editButton = nil;
	
	[doneButton release];
	doneButton = nil;
	[_searchBar release];
	_searchBar = nil;
	[_segmentedControl release];
	_segmentedControl = nil;
	[_searchScopeDefinition release];
	_searchScopeDefinition = nil;
	[_defaultSearchScope release];
	_defaultSearchScope = nil;
    [_searchBlock release];
    _searchBlock = nil;
    
    [_rowInsertAnimationBlock release];
    _rowInsertAnimationBlock = nil;
    [_rowRemoveAnimationBlock release];
    _rowRemoveAnimationBlock = nil;
    [_sectionInsertAnimationBlock release];
    _sectionInsertAnimationBlock = nil;
    [_sectionRemoveAnimationBlock release];
    _sectionRemoveAnimationBlock = nil;
    
    [super dealloc];
}


#pragma mark UIViewController Implementation

- (void)viewDidLoad{
    [super viewDidLoad];
      
    if(self.tableView.delegate == nil){
        self.tableView.delegate = self;
    }
    if(self.tableView.dataSource == nil){
        self.tableView.dataSource = self;
    }
    
    [self adjustTableView];
    
    if(!_registeredToContentSize){
        [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        _registeredToContentSize = YES;
    }
}

- (void)viewDidUnload{
    [self.weakViews removeAllObjects];
    [self.viewsToControllers removeAllObjects];
    [self.viewsToIndexPath removeAllObjects];
    [self.indexPathToViews removeAllObjects];
    
    [_searchBar release];
    _searchBar = nil;
    
    [_segmentedControl release];
    _segmentedControl = nil;
    
    if(_registeredToContentSize){
        [self.tableView removeObserver:self forKeyPath:@"contentSize"];
        _registeredToContentSize = NO;
    }

    [super viewDidUnload];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    //Adds searchbars if needed
    CGFloat tableViewOffset = 0;
    if(self.searchBar){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
        BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        BOOL isIpad = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        if(!isIpad){
            if(_searchScopeDefinition && isPortrait){
                tableViewOffset = 88;
            }
            else{
                tableViewOffset = 44;
            }
        }
        else{
            BOOL tooSmall = self.view.bounds.size.width <= 320;
            if(_searchScopeDefinition && tooSmall){
                tableViewOffset = 88;
            }
            else{
                tableViewOffset = 44;
            }
        }
        
        UIEdgeInsets tableInsets = [self navigationControllerTransparencyInsets];
        
        self.searchBar.frame = CGRectMake(0,tableInsets.top,self.tableView.frame.size.width,tableViewOffset);
    }
    
    if(_segmentedControl){
        _segmentedControl.frame = CGRectMake(0,tableViewOffset,self.tableView.frame.size.width,44);
    }

}

- (void)viewWillAppear:(BOOL)animated {
    CKViewControllerAnimatedBlock oldViewWillAppearEndBlock = [self.viewWillAppearEndBlock copy];
    self.viewWillAppearEndBlock = nil;
    
    
	[self.objectController lock];
    
    /*
    self.tableView.delegate = _storedTableDelegate;
    self.tableView.dataSource = _storedTableDataSource;
    */
    
    [super viewWillAppear:animated];
	
  //  if([CKOSVersion() floatValue] < 7){
        //apply width constraint

        
        //Adds searchbars if needed
        CGFloat tableViewOffset = 0;
        if(self.searchEnabled && self.searchDisplayController == nil && _searchBar == nil){
            UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
            BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
            BOOL isIpad = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad);
            if(!isIpad){
                if(_searchScopeDefinition && isPortrait){
                    tableViewOffset = 88;
                }
                else{
                    tableViewOffset = 44;
                }
            }
            else{
                BOOL tooSmall = self.view.bounds.size.width <= 320;
                if(_searchScopeDefinition && tooSmall){
                    tableViewOffset = 88;
                }
                else{
                    tableViewOffset = 44;
                }
            }
            
            UIEdgeInsets tableInsets = [self navigationControllerTransparencyInsets];
            
            self.searchBar = [[[UISearchBar alloc]initWithFrame:CGRectMake(0,tableInsets.top,self.tableView.frame.size.width,tableViewOffset)]autorelease];
            _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _searchBar.delegate = self;
            //self.tableView.tableHeaderView = _searchBar;
            [self.view addSubview:_searchBar];
            
            
            if(_searchScopeDefinition){
                _searchBar.showsScopeBar = YES;
                _searchBar.scopeButtonTitles = [_searchScopeDefinition allKeys];
                if(_defaultSearchScope){
                    _searchBar.selectedScopeButtonIndex = [[_searchScopeDefinition allKeys]indexOfObject:_defaultSearchScope];
                }
            }
            [[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self]autorelease];
        }
        
        //adds segmented control on top if search disable and found _searchScopeDefinition
        if(self.searchEnabled == NO && _searchScopeDefinition && [_searchScopeDefinition count] > 0 && _segmentedControl == nil){
            self.segmentedControl = [[[UISegmentedControl alloc]initWithItems:[_searchScopeDefinition allKeys]]autorelease];
            if(_defaultSearchScope){
                _segmentedControl.selectedSegmentIndex = [[_searchScopeDefinition allKeys]indexOfObject:_defaultSearchScope];
            }
            _segmentedControl.frame = CGRectMake(0,tableViewOffset,self.tableView.frame.size.width,44);
            _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [_segmentedControl addTarget:self
                                  action:@selector(segmentedControlChange:)
                        forControlEvents:UIControlEventValueChanged];
            [self.view addSubview:_segmentedControl];
            tableViewOffset += 44;
        }
        
      //  if(self.tableViewContainer.frame.origin.y < tableViewOffset){
       //     self.tableViewContainer.frame = CGRectMake(self.tableViewContainer.frame.origin.x,self.tableViewContainer.frame.origin.y + tableViewOffset,
       //                                                self.tableViewContainer.frame.size.width,self.tableViewContainer.frame.size.height - tableViewOffset);
       // }
	//}
  //  [self sizeToFit];
    
    NSMutableDictionary* controllerStyle = [self controllerStyle];
    NSMutableDictionary* navControllerStyle = [controllerStyle styleForObject:self.navigationController  propertyName:@"navigationController"];
	NSMutableDictionary* navBarStyle = [navControllerStyle styleForObject:self.navigationController  propertyName:@"navigationBar"];
    
    if(!self.editButton){
        self.editButton = [[[UIBarButtonItem alloc] initWithTitle:_(@"Edit") style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)]autorelease];
    }
    if(!self.doneButton){
        self.doneButton = [[[UIBarButtonItem alloc] initWithTitle:_(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(edit:)]autorelease];
    }
    
    if(self.editButton){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.editButton propertyName:@"editBarButtonItem"];
        [self.editButton applyStyle:barItemStyle];
    }
    if(self.doneButton){
        NSMutableDictionary* barItemStyle = [navBarStyle styleForObject:self.doneButton propertyName:@"doneBarButtonItem"];
        [self.doneButton applyStyle:barItemStyle];
    }
    
	[self createsAndDisplayEditableButtonsWithType:_editableType animated:animated];
	
	if ([CKOSVersion() floatValue] < 3.2) {
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
	}
	
	[self updateVisibleViewsRotation];
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self adjustTableView];
	}
	
	if(_indexPathToReachAfterRotation){
		//adjust _indexPathToReachAfterRotation to the nearest valid indexpath
		NSInteger currentRow = _indexPathToReachAfterRotation.row;
		NSInteger currentSection = _indexPathToReachAfterRotation.section;
		NSInteger rowCount = [self numberOfObjectsForSection:currentSection];
		if(currentRow >= rowCount){
			if(rowCount > 0){
				currentRow = rowCount - 1;
			}
			else{
				currentSection = currentSection - 1;
				while(currentSection >= 0){
					NSInteger rowCount = [self numberOfObjectsForSection:currentSection];
					if(rowCount > 0){
						currentRow = rowCount - 1;
						currentSection = currentSection;
						break;
					}
					currentSection--;
				}
			}
		}
		
		if (currentRow >= 0 && currentSection >= 0){
            BOOL pagingEnable = self.tableView.pagingEnabled;
            self.tableView.pagingEnabled = NO;
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:currentSection] atScrollPosition:UITableViewScrollPositionNone animated:NO];
            self.tableView.pagingEnabled = pagingEnable;
            
            self.indexPathToReachAfterRotation = [NSIndexPath indexPathForRow:currentRow inSection:currentSection];
		}
	}
	
	[self updateNumberOfPages];
	
	[self.objectController unlock];
	
	for(int i =0; i< [self numberOfSections];++i){
		[self fetchMoreIfNeededFromIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
	}
    
    [self tableViewFrameChanged:nil];
    
    if(self.tableView.hidden == NO){
        [self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4];
    }
    [NSObject beginBindingsContext:_bindingContextForTableView policy:CKBindingsContextPolicyRemovePreviousBindings];
    [self.tableView bind:@"hidden" target:self action:@selector(tableViewVisibilityChanged:)];
	[self.tableViewContainer bind:@"bounds" target:self action:@selector(tableViewFrameChanged:)];
    [NSObject endBindingsContext];

    if(oldViewWillAppearEndBlock){
        oldViewWillAppearEndBlock(self,animated);
        self.viewWillAppearEndBlock = [oldViewWillAppearEndBlock autorelease];
    }
    
}


- (CGFloat)additionalTopContentOffset{
    CGFloat tableViewOffset = 0;
    if(self.searchEnabled && _searchBar != nil){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication]statusBarOrientation];
        BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
        BOOL isIpad = ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad);
        if(!isIpad){
            if(_searchScopeDefinition && isPortrait){
                tableViewOffset = 88;
            }
            else{
                tableViewOffset = 44;
            }
        }
        else{
            BOOL tooSmall = self.view.bounds.size.width <= 320;
            if(_searchScopeDefinition && tooSmall){
                tableViewOffset = 88;
            }
            else{
                tableViewOffset = 44;
            }
        }
    }
    
    return tableViewOffset;
}

- (void)sizeToFit{
    [super sizeToFit];
}

- (void)tableViewVisibilityChanged:(NSNumber*)hidden{
    if(![hidden boolValue]){
        [self performSelector:@selector(updateViewsVisibility:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	self.indexPathToReachAfterRotation = nil;
	
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CGRect f = [self.tableView rectForRowAtIndexPath:indexPath];
		if(f.origin.y >= self.tableView.contentOffset.y){
			self.indexPathToReachAfterRotation = indexPath;
			break;
		}
	}
	
	if(!_indexPathToReachAfterRotation && [visibleIndexPaths count] > 0){
		NSIndexPath *indexPath = [visibleIndexPaths objectAtIndex:0];
		self.indexPathToReachAfterRotation = indexPath;
	}
	 
	[super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(object == self.tableView && [keyPath isEqualToString:@"contentSize"]){
        [self updateNumberOfPages];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetWillShow:) name:CKSheetWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sheetWillHide:) name:CKSheetWillHideNotification object:nil];
    
    self.indexPathToReachAfterRotation = nil;
}

- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
    /*
    _storedTableDelegate = self.tableView.delegate;
    self.tableView.delegate = nil;
    _storedTableDataSource = self.tableView.dataSource;
    self.tableView.dataSource = nil;
     */
	
	//keyboard notifications
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CKSheetWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CKSheetWillHideNotification object:nil];
    
	[NSObject removeAllBindingsForContext:_bindingContextForTableView];
}


- (void)reload{
	if(self.isViewDisplayed){
		[super reload];
        if(self.autoFetchCollections || ([self.objectController isKindOfClass:[CKCollectionController class]] && [((CKCollectionController*)self.objectController).collection count] <= 0) ){
            [self fetchMoreData];
        }
	}
}

#pragma mark Orientation Management

- (void)rotateSubViewsForCell:(UITableViewCell*)cell{
	if(_orientation == CKTableViewOrientationLandscape){
		UIView* view = cell.contentView;
		CGRect frame = view.frame;
		view.transform = CGAffineTransformMakeRotation(M_PI/2);
		
		if ([CKOSVersion() floatValue] < 3.2) {
			view.frame = frame;
			
			for(UIView* v in view.subviews){
				//UIViewAutoresizing resizingMasks = v.autoresizingMask;
				v.autoresizingMask = UIViewAutoresizingNone;
				v.center = CGPointMake((NSInteger)(cell.contentView.bounds.size.width / 2.0),(NSInteger)(cell.contentView.bounds.size.height / 2.0));
				v.frame = cell.contentView.bounds;
				//v.autoresizingMask = resizingMasks; //reizing masks break the layout on os 3
			}
		}
	}
}

- (void)adjustView{
    if(self.tableViewContainer == nil)
        return;
    
	if(_orientation == CKTableViewOrientationLandscape) {
		CGRect frame = self.tableViewContainer.frame;
		self.tableViewContainer.transform = CGAffineTransformMakeRotation(-M_PI/2);
		self.tableViewContainer.frame = frame;
	}
}

- (void)adjustTableView{
    if(self.tableViewContainer == nil)
        return;
    
	[self adjustView];
	
	if(_orientation == CKTableViewOrientationLandscape) {
		self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.tableView.frame = CGRectMake(0,0,self.tableViewContainer.bounds.size.width,self.tableViewContainer.bounds.size.height);
	}
	
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
		[self rotateSubViewsForCell:(UITableViewCell*)controller.view];
	}
}

- (void)setOrientation:(CKTableViewOrientation)orientation {
	_orientation = orientation;
    
    if(self.objectController != nil && [self.objectController respondsToSelector:@selector(setAppendSpinnerAsFooterCell:)]){
		[self.objectController setAppendSpinnerAsFooterCell:(self.orientation == CKTableViewOrientationPortrait)];
	}
    
	[self adjustView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//stop scrolling
	[self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y) animated:NO];
	
	self.indexPathToReachAfterRotation = nil;
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CGRect f = [self.tableView rectForRowAtIndexPath:indexPath];
		if(f.origin.y >= self.tableView.contentOffset.y){
			self.indexPathToReachAfterRotation = indexPath;
			break;
		}
	}
	
	if(!_indexPathToReachAfterRotation && [visibleIndexPaths count] > 0){
		NSIndexPath *indexPath = [visibleIndexPaths objectAtIndex:0];
		self.indexPathToReachAfterRotation = indexPath;
	}
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
	
	if ([CKOSVersion() floatValue] < 3.2) {
		[self adjustTableView];
	}
	[super willAnimateRotationToInterfaceOrientation:interfaceOrientation duration:duration];
}
 
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if([self isValidIndexPath:_indexPathToReachAfterRotation]){
        BOOL pagingEnable = self.tableView.pagingEnabled;
        if(pagingEnable){
            self.tableView.pagingEnabled = NO;
            [self.tableView scrollToRowAtIndexPath:_indexPathToReachAfterRotation atScrollPosition:UITableViewScrollPositionNone animated:NO];
            self.tableView.pagingEnabled = pagingEnable;
        }
    }
	self.indexPathToReachAfterRotation = nil;
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.tableViewHasBeenReloaded ? [self numberOfSections] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.tableViewHasBeenReloaded ? [self numberOfObjectsForSection:section] : 0;
}

- (CGSize)sizeForViewAtIndexPath:(NSIndexPath*)indexPath{
    CKTableViewCellController* controller = (CKTableViewCellController*)[self controllerAtIndexPath:indexPath];
    controller.sizeHasBeenQueriedByTableView = YES;
    if(controller.invalidatedSize){
        CGSize size;
        if(controller.sizeBlock){
            size = controller.sizeBlock(controller);
        }else{
            size = [controller computeSize];
        }
        [controller setSize:size notifyingContainerForUpdate:NO];
    }
    return controller.size;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
    CGFloat height = 0;
	CGSize thesize = [self sizeForViewAtIndexPath:indexPath];
	height = (_orientation == CKTableViewOrientationLandscape) ? thesize.width : thesize.height;
	
    if(self.tableView.pagingEnabled){
        NSIndexPath* toReach = [[_indexPathToReachAfterRotation copy]autorelease];
        if(_indexPathToReachAfterRotation && [_indexPathToReachAfterRotation isEqual:indexPath]){
            //that means the view is rotating and needs to be updated with the future cells size
            self.indexPathToReachAfterRotation = nil;
            CGFloat offset = 0;
            if(toReach.row > 0){
                CGRect r = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:toReach.row-1 inSection:toReach.section]];
                offset = r.origin.y + r.size.height;
            }
            else{
                CGRect r = [self.tableView rectForHeaderInSection:toReach.section];
                offset = r.origin.y + r.size.height;
            }
            self.indexPathToReachAfterRotation = toReach;
            self.tableView.contentOffset = CGPointMake(0,offset);
        }
    }
	
	//NSLog(@"Height for row : %d,%d =%f",indexPath.row,indexPath.section,height);
	
	return (height < 0) ? 0 : ((height == 0) ? self.tableView.rowHeight : height);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIView* view = [self createViewAtIndexPath:indexPath];
    
    if (![view isKindOfClass:[UITableViewCell class]])
        [NSException raise:NSGenericException format:@"invalid type for view"];
	
	return (UITableViewCell*)view;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKTableViewCellController* controller = (CKTableViewCellController*) [self controllerAtIndexPath:indexPath];
    return controller.indentationLevel;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	[self rotateSubViewsForCell:cell];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if([self willSelectViewAtIndexPath:indexPath]){
        [self selectRowAtIndexPath:indexPath animated:YES];
		return indexPath;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.searchBar resignFirstResponder];
	[self didSelectViewAtIndexPath:indexPath];
    if(self.delegate && [self.delegate respondsToSelector:@selector(objectTableViewController:didSelectRowAtIndexPath:withObject:)]) {
        [self.delegate objectTableViewController:self didSelectRowAtIndexPath:indexPath withObject:[self objectAtIndexPath:indexPath] ];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	CKItemViewFlags flags = [self flagsForViewAtIndexPath:indexPath];
	BOOL bo = flags & CKItemViewFlagRemovable;
	return bo ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
	[self didSelectAccessoryViewAtIndexPath:indexPath];
    if(self.delegate && [self.delegate respondsToSelector:@selector(objectTableViewController:didSelectAccessoryViewRowAtIndexPath:withObject:)]) {
        [self.delegate objectTableViewController:self didSelectAccessoryViewRowAtIndexPath:indexPath withObject:[self objectAtIndexPath:indexPath] ];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete){
		[self didRemoveViewAtIndexPath:indexPath];
        //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:self.rowRemoveAnimation];
		[self fetchMoreIfNeededFromIndexPath:indexPath];
        self.editButton.enabled = YES;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    /*if(self.editableType == CKTableCollectionViewControllerEditingTypeNone
       || self.editing == NO)
        return NO;*/
    
	return [self isViewEditableAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if(/*self.editableType == CKTableCollectionViewControllerEditingTypeNone
       || */self.editing == NO && self.tableView.editing == NO)
        return NO;
    
	return [self isViewMovableAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	return [self targetIndexPathForMoveFromIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	[self didMoveViewAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
}


#pragma mark UITableView Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    UIView* view = [self tableView:self.tableView viewForHeaderInSection:section];
	if(view){
        return nil;
    }
    
    if([self.objectController respondsToSelector:@selector(headerTitleForSection:)]){
        return [self.objectController headerTitleForSection:section];
    }
    
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	CGFloat height = 0;
	UIView* view = [self tableView:self.tableView viewForHeaderInSection:section];
	if(view){
		height = view.frame.size.height;
	}
	
	if(height <= 0){
        if([self.objectController respondsToSelector:@selector(headerTitleForSection:)]){
            NSString* title = [self.objectController headerTitleForSection:section];
            if( title != nil && [title length] > 0 ){
                return -1;
            }
        }
	}
	return height;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([self.objectController respondsToSelector:@selector(headerViewForSection:)]){
        UIView* view = [self.objectController headerViewForSection:section];
        if(view && [view appliedStyle] == nil){
            NSMutableDictionary* style = [self controllerStyle];
            [view applyStyle:style propertyName:@"sectionHeaderView"];
        }
        return view;
    }

	return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    UIView* view = [self tableView:self.tableView viewForFooterInSection:section];
	if(view){
        return nil;
    }
    if([self.objectController respondsToSelector:@selector(footerTitleForSection:)]){
        return [self.objectController footerTitleForSection:section];
    }
	return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	CGFloat height = 0;
	UIView* view = [self tableView:self.tableView viewForFooterInSection:section];
	if(view){
		height = view.frame.size.height;
	}
	
	if(height <= 0){
        if([self.objectController respondsToSelector:@selector(footerTitleForSection:)]){
            NSString* title = [self.objectController footerTitleForSection:section];
            if( title != nil && [title length] > 0 ){
                return -1;
            }
        }
	}
	return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if([self.objectController respondsToSelector:@selector(footerViewForSection:)]){
        UIView* view = [self.objectController footerViewForSection:section];
        if(view && [view appliedStyle] == nil){
            NSMutableDictionary* style = [self controllerStyle];
            [view applyStyle:style propertyName:@"sectionFooterView"];
        }
        return view;
    }
	return nil;
}

#pragma mark CKCollectionViewController Implementation

- (void)updateVisibleViewsRotation{
    //Rotate views for visible controllers.
	NSArray *visibleIndexPaths = [self visibleIndexPaths];
	for (NSIndexPath *indexPath in visibleIndexPaths) {
		CKCollectionCellController* controller = [self controllerAtIndexPath:indexPath];
		if([controller respondsToSelector:@selector(rotateView:animated:)]){
			[controller rotateView:controller.view animated:YES];
			
			if ([CKOSVersion() floatValue] < 3.2) {
				[self rotateSubViewsForCell:(UITableViewCell*)controller.view];
			}
		}
	}	
}

- (void)didBeginUpdates{
	if(!self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
	
   [self.tableView beginUpdates];
}

- (void)didEndUpdates{
	if(!self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
	
   [self.tableView endUpdates];
    
  //  [self sizeToFit];
}

- (void)didInsertObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(!self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
	
    UITableViewRowAnimation anim = self.rowInsertAnimationBlock(self,objects,indexPaths);
   // if(anim == UITableViewRowAnimationNone){
   //     [self.tableView reloadData];
   // }else{
    //    [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:anim];
    //    [self.tableView endUpdates];
   // }
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath){
		int count = 0;
		for(NSIndexPath* indexPath in indexPaths){
			if(indexPath.section == self.selectedIndexPath.section){
				if(indexPath.row <= self.selectedIndexPath.row){
					count++;
				}
			}
		}
		self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row + count inSection:self.selectedIndexPath.section];
	}
}

- (void)didRemoveObjects:(NSArray*)objects atIndexPaths:(NSArray*)indexPaths{
	if(!self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
 //   NSLog(@"didRemoveObjects <%@>",self);
	
    UITableViewRowAnimation anim = self.rowRemoveAnimationBlock(self,objects,indexPaths);
  //  if(anim == UITableViewRowAnimationNone){
  //      [self.tableView reloadData];
  //  }else{
   //     [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:anim];
   //     [self.tableView endUpdates];
   // }
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath){
		int count = 0;
		for(NSIndexPath* indexPath in indexPaths){
			if([indexPath isEqual:self.selectedIndexPath]){
				self.selectedIndexPath = nil;
				break;
			}
			
			if(indexPath.section == self.selectedIndexPath.section){
				if(indexPath.row <= self.selectedIndexPath.row){
					count++;
				}
			}
		}
		
		if(self.selectedIndexPath){
			self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row - count inSection:self.selectedIndexPath.section];
		}
	}
}

- (void)didInsertSectionAtIndex:(NSInteger)index{
	if(!self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
    
    UITableViewRowAnimation anim = self.sectionInsertAnimationBlock(self,index);
   // if(anim == UITableViewRowAnimationNone){
   //     [self.tableView reloadData];
   // }else{
   //     [self.tableView beginUpdates];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:anim];
   //     [self.tableView endUpdates];
    //}
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath && self.selectedIndexPath.section >= index){
		self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:self.selectedIndexPath.section + 1];
	}
}

- (void)didRemoveSectionAtIndex:(NSInteger)index{
	if(!self.isViewDisplayed){
        self.tableViewHasBeenReloaded = NO;
		return;
    }
    
    UITableViewRowAnimation anim = self.sectionRemoveAnimationBlock(self,index);
   // if(anim == UITableViewRowAnimationNone){
   //     [self.tableView reloadData];
   // }else{
   //     [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:anim];
   //     [self.tableView endUpdates];
   // }
	
	//UPDATE STICKY SELECTION INDEX PATH
	if(self.selectedIndexPath && self.selectedIndexPath.section > index){
		self.selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:self.selectedIndexPath.section - 1];
	}
}

- (void)setObjectController:(id)controller{
	[super setObjectController:controller];
	if(self.objectController != nil && [self.objectController respondsToSelector:@selector(setAppendSpinnerAsFooterCell:)]){
		[self.objectController setAppendSpinnerAsFooterCell:(self.orientation == CKTableViewOrientationPortrait)];
	}
}

- (UIView*)dequeueReusableViewWithIdentifier:(NSString*)identifier forIndexPath:(NSIndexPath*)indexPath{
	return [self.tableView dequeueReusableCellWithIdentifier:identifier];
}

#pragma mark SearchBar Management

- (void)didSearch:(NSString*)text{
        //if we want to implement it in subclass ..
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self.searchBar resignFirstResponder];
	
	if ([searchBar.text isEqualToString:@""] == NO){
		if(self.delegate && [self.delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
			[self.delegate objectTableViewController:self didSearch:searchBar.text];
		}
        if(_searchBlock){
            _searchBlock(searchBar.text);
        }
		[self didSearch:searchBar.text];
	}
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	/*[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if ([searchBar.text isEqualToString:@""] == YES){
		if(self.delegate && [self.delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
			[self.delegate objectTableViewController:self didSearch:@""];
		}
        
        if(_searchBlock){
            _searchBlock(searchBar.text);
        }
		[self didSearch:searchBar.text];
	}*/
}

- (void)delayedSearchWithText:(NSString*)str{
	if (self.delegate && [self.delegate respondsToSelector:@selector(objectTableViewController:didSearch:)]) {
		[self.delegate objectTableViewController:self didSearch:str];
	}
    
    if(_searchBlock){
        _searchBlock(str);
    }
	[self didSearch:str];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	if(_liveSearchDelay > 0){
		[self performSelector:@selector(delayedSearchWithText:) withObject:searchBar.text afterDelay:_liveSearchDelay];
	}
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
	NSInteger index = selectedScope;
	id key = [[_searchScopeDefinition allKeys]objectAtIndex:index];
	id value = [_searchScopeDefinition objectForKey:key];
    if (![value isKindOfClass:[CKCallback class]])
        [NSException raise:NSGenericException format:@"invalid object in segmentDefinition"];
	CKCallback* callback = (CKCallback*)value;
	[callback execute:self];	
}

- (void)segmentedControlChange:(id)sender{
	NSInteger index = _segmentedControl.selectedSegmentIndex;
	id key = [[_searchScopeDefinition allKeys]objectAtIndex:index];
	id value = [_searchScopeDefinition objectForKey:key];
    if (![value isKindOfClass:[CKCallback class]])
        [NSException raise:NSGenericException format:@"invalid object in segmentDefinition"];
	CKCallback* callback = (CKCallback*)value;
	[callback execute:self];
}



#pragma mark Edit Button Management

- (void)editableTypeExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKBitMaskDefinition(@"CKTableCollectionViewControllerEditingType",
                                                    CKTableCollectionViewControllerEditingTypeNone,
                                                    CKTableCollectionViewControllerEditingTypeLeft,
                                                    CKTableCollectionViewControllerEditingTypeRight,
                                                    CKTableCollectionViewControllerEditingTypeAnimateTransition);
}

- (IBAction)edit:(id)sender{
    [self setEditing:!self.editing animated:YES];
}

- (void)setEditing:(BOOL)editing{
    [super setEditing:editing];
    [self createsAndDisplayEditableButtonsWithType:_editableType animated:([CKOSVersion() floatValue] >= 5)];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self createsAndDisplayEditableButtonsWithType:_editableType animated:([CKOSVersion() floatValue] >= 5)];
}

- (void)createsAndDisplayEditableButtonsWithType:(CKTableCollectionViewControllerEditingType)type animated:(BOOL)animated{
    if(type & CKTableCollectionViewControllerEditingTypeLeft){
        self.leftButton = ((self.navigationItem.leftBarButtonItem != self.editButton) && (self.navigationItem.leftBarButtonItem != self.doneButton)) ?  self.navigationItem.leftBarButtonItem : nil;
        [self.navigationItem setLeftBarButtonItem:(self.editing) ? self.doneButton : self.editButton animated:(type & CKTableCollectionViewControllerEditingTypeAnimateTransition)];
        [self applyStyleForLeftBarButtonItem];
    }
    else  if(type & CKTableCollectionViewControllerEditingTypeRight){
        self.rightButton = ((self.navigationItem.rightBarButtonItem != self.editButton) && (self.navigationItem.rightBarButtonItem != self.doneButton)) ?  self.navigationItem.rightBarButtonItem : nil;
        [self.navigationItem setRightBarButtonItem:(self.editing) ? self.doneButton : self.editButton animated:(type & CKTableCollectionViewControllerEditingTypeAnimateTransition)];
        [self applyStyleForRightBarButtonItem];
    }
}

- (void)setEditableType:(CKTableCollectionViewControllerEditingType)theEditableType{
    if(theEditableType != _editableType && self.isViewDisplayed){
        if(_editableType & CKTableCollectionViewControllerEditingTypeLeft){
            if(self.leftButton){
                [self.navigationItem setLeftBarButtonItem:self.leftButton animated:(_editableType & CKTableCollectionViewControllerEditingTypeAnimateTransition)];
            }
            else{
                [self.navigationItem setLeftBarButtonItem:nil animated:(_editableType & CKTableCollectionViewControllerEditingTypeAnimateTransition)];
            }
            [self applyStyleForLeftBarButtonItem];
        }
        else if(_editableType & CKTableCollectionViewControllerEditingTypeRight){
            if(self.rightButton){
                [self.navigationItem setRightBarButtonItem:self.rightButton animated:(_editableType & CKTableCollectionViewControllerEditingTypeAnimateTransition)];
            }
            else{
                [self.navigationItem setRightBarButtonItem:nil animated:(_editableType & CKTableCollectionViewControllerEditingTypeAnimateTransition)];
            }
            [self applyStyleForRightBarButtonItem];
        }
        
        if((_editableType & CKTableCollectionViewControllerEditingTypeLeft) || (_editableType & CKTableCollectionViewControllerEditingTypeRight)){
			_editableType = theEditableType;
            [self createsAndDisplayEditableButtonsWithType:theEditableType animated:YES];
        }
        else{
			_editableType = theEditableType;
            if([self isEditing]){
                [self setEditing:NO animated:YES];
            }
        }
    }
    _editableType = theEditableType;
}

- (void)tableViewCellController:(CKTableViewCellController*)controller displaysDeletionAtIndexPath:(NSIndexPath*)indexPath{
    self.editButton.enabled = NO;
}

- (void)tableViewCellController:(CKTableViewCellController*)controller hidesDeletionAtIndexPath:(NSIndexPath*)indexPath{
    self.editButton.enabled = YES;
}


#pragma mark Keyboard Notifications

- (void)stretchTableDownUsingRect:(CGRect)endFrame animationCurve:(UIViewAnimationCurve)animationCurve duration:(NSTimeInterval)animationDuration{
    if (_resizeOnKeyboardNotification == YES && _orientation == CKTableViewOrientationPortrait){
        CGRect keyboardFrame = [[self.tableViewContainer window] convertRect:endFrame toView:self.tableViewContainer];
        CGFloat offset = self.tableViewContainer.frame.size.height - keyboardFrame.origin.y;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        self.tableView.contentInset =  UIEdgeInsetsMake(self.tableView.contentInset.top,0,self.tableView.contentInset.bottom + offset, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top,0,self.tableView.scrollIndicatorInsets.bottom+offset, 0);
        [UIView commitAnimations];
    }
}

- (void)stretchBackToPreviousFrameUsingAnimationCurve:(UIViewAnimationCurve)animationCurve duration:(NSTimeInterval)animationDuration{
    if (_resizeOnKeyboardNotification == YES && _orientation == CKTableViewOrientationPortrait){
        if(_modalViewCount <= 0){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:animationCurve];
            [self adjustTableViewInsets];
            
            [UIView commitAnimations];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (_resizeOnKeyboardNotification == YES && _orientation == CKTableViewOrientationPortrait){
        if(_modalViewCount == 0){
            _modalViewCount = 1;
            NSDictionary *info = [notification userInfo];
            CGRect keyboardEndFrame;
            NSTimeInterval animationDuration;
            UIViewAnimationCurve animationCurve;
            [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
            [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
            [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
            [self stretchTableDownUsingRect:keyboardEndFrame animationCurve:animationCurve duration:animationDuration];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (_resizeOnKeyboardNotification == YES && _orientation == CKTableViewOrientationPortrait){
        if(_modalViewCount == 1){
            _modalViewCount = 0;
        }
        NSDictionary *info = [notification userInfo];
        NSTimeInterval animationDuration;
        UIViewAnimationCurve animationCurve;
        [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
        [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
        [self stretchBackToPreviousFrameUsingAnimationCurve:animationCurve duration:animationDuration];
    }
}

- (void)sheetWillShow:(NSNotification *)notification {
    if (_resizeOnKeyboardNotification == YES && _orientation == CKTableViewOrientationPortrait){
        if(_modalViewCount == 0){
            _modalViewCount = 2;
            NSDictionary *info = [notification userInfo];
            CGRect keyboardEndFrame = [[info objectForKey:CKSheetFrameEndUserInfoKey] CGRectValue];
            UIViewAnimationCurve animationCurve = (UIViewAnimationCurve)[[info objectForKey:CKSheetAnimationCurveUserInfoKey] intValue];
            NSTimeInterval animationDuration = [[info objectForKey:CKSheetAnimationDurationUserInfoKey] floatValue];
            [self stretchTableDownUsingRect:keyboardEndFrame animationCurve:animationCurve duration:animationDuration];
        }
    }
}

- (void)sheetWillHide:(NSNotification *)notification {
    if (_resizeOnKeyboardNotification == YES && _orientation == CKTableViewOrientationPortrait){
        if(_modalViewCount == 2){
            _modalViewCount = 0;
        }
        NSDictionary *info = [notification userInfo];
        UIViewAnimationCurve animationCurve = (UIViewAnimationCurve)[[info objectForKey:CKSheetAnimationCurveUserInfoKey] intValue];
        NSTimeInterval animationDuration = [[info objectForKey:CKSheetAnimationDurationUserInfoKey] floatValue];
        BOOL keyboardWillShow = [[info objectForKey:CKSheetKeyboardWillShowInfoKey]boolValue];
        if(!keyboardWillShow){
            [self stretchBackToPreviousFrameUsingAnimationCurve:animationCurve duration:animationDuration];
        }
    }
}

#pragma mark Paging And Snapping

- (void)setCurrentPage:(int)page{
	_currentPage = page;
        //NSLog(@"currentPage = %d",_currentPage);
        //TODO : scroll to the right controller ???
}

- (void)setNumberOfPages:(int)pages{
	_numberOfPages = pages;
        //NSLog(@"number of pages = %d",_numberOfPages);
        //TODO : scroll to the right controller ???
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

- (void)executeScrollingPolicy{
    switch(_scrollingPolicy){
        case CKTableCollectionViewControllerScrollingPolicyNone:{
            break;
        }
        case CKTableCollectionViewControllerScrollingPolicyResignResponder:{
            [self.view endEditing:YES];
            [[NSNotificationCenter defaultCenter]postNotificationName:CKSheetResignNotification object:nil];
            break;
        }
    }
}

- (NSIndexPath*)snapIndexPath{
    CGFloat offset = self.tableView.contentOffset.y;
    offset += self.tableView.bounds.size.height / 2.0;
    
    if(offset < 0){ offset = 0; }
    if(offset > self.tableView.contentSize.height){ offset = self.tableView.contentSize.height; }
    
    for(NSIndexPath* indexPath in self.visibleIndexPaths){
        UIView* v = [self viewAtIndexPath:indexPath];
        CGRect rect = v.frame;
        if(rect.origin.y <= offset && rect.origin.y + rect.size.height >= offset){
            return indexPath;
        }
    }
    
    return nil;
}

- (void)executeSnapPolicy{
    switch(_snapPolicy){
        case CKTableCollectionViewControllerSnappingPolicyNone:{
            break;
        }
        case CKTableCollectionViewControllerSnappingPolicyCenter:{
            NSIndexPath* indexPath = [self snapIndexPath];
            if(indexPath != nil){
                NSIndexPath * indexPath2 = [self tableView:self.tableView willSelectRowAtIndexPath:indexPath];
                if(indexPath2){
                    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath2];
                }
            }
            break;
        }
    }
}

- (void)tableViewFrameChanged:(id)value{
    switch(_snapPolicy){
        case CKTableCollectionViewControllerSnappingPolicyNone:{
            break;
        }
        case CKTableCollectionViewControllerSnappingPolicyCenter:{
            //FIXME : we do not take self.tableViewInsets in account here
            CGFloat toolbarHeight = self.navigationController.isToolbarHidden ? 0 : self.navigationController.toolbar.bounds.size.height;
            self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.bounds.size.height / 2.0,0,self.tableView.bounds.size.height / 2.0 + toolbarHeight,0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            if (self.selectedIndexPath && [self isValidIndexPath:self.selectedIndexPath]
                && self.snapPolicy == CKTableCollectionViewControllerSnappingPolicyCenter){
                [self selectRowAtIndexPath:self.selectedIndexPath animated:(self.state == CKViewControllerStateDidAppear) ? YES : NO];
            }
            
            break;
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
	[self updateCurrentPage];
	[self updateViewsVisibility:YES];
    if(self.autoFetchCollections){
        [self fetchMoreData];
    }
    self.scrolling = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[self updateCurrentPage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
	[self updateCurrentPage];
	if(self.autoFetchCollections){
        [self fetchMoreData];
    }
    self.scrolling = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self executeScrollingPolicy];
    self.scrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate || scrollView.decelerating)
		return;
    
	[self updateViewsVisibility:YES];
    [self executeSnapPolicy];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self updateCurrentPage];
	[self updateViewsVisibility:YES];
	if(self.autoFetchCollections){
        [self fetchMoreData];
    }
    [self executeSnapPolicy];
    self.scrolling = NO;
}

- (void)scrollToRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
    if([self isValidIndexPath:indexPath]){
        if(self.state == CKViewControllerStateDidAppear ||
           self.state == CKViewControllerStateWillAppear){
            
            if(self.snapPolicy == CKTableCollectionViewControllerSnappingPolicyCenter){
                CGRect r = [self.tableView rectForRowAtIndexPath:indexPath];
                CGFloat offset = r.origin.y + (r.size.height / 2.0);
                offset -= self.tableView.contentInset.top;
                [self.tableView setContentOffset:CGPointMake(0,offset) animated:animated];
            }
            else{
                [self.tableView scrollToRowAtIndexPath:indexPath 
                                      atScrollPosition:UITableViewScrollPositionMiddle 
                                              animated:animated];
            }
        }
        self.indexPathToReachAfterRotation = indexPath;
    }
}

- (void)selectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
    if([self isValidIndexPath:indexPath]){
        if(self.state == CKViewControllerStateDidAppear ||
           self.state == CKViewControllerStateWillAppear){
            if(self.snapPolicy == CKTableCollectionViewControllerSnappingPolicyCenter){
                CGRect r = [self.tableView rectForRowAtIndexPath:indexPath];
                CGFloat offset = r.origin.y + (r.size.height / 2.0);
                offset -= self.tableView.contentInset.top;
                [self.tableView selectRowAtIndexPath:indexPath
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
                [self.tableView setContentOffset:CGPointMake(0,offset) animated:animated];
            }
            else{
                [self.tableView selectRowAtIndexPath:indexPath
                                            animated:animated
                                      scrollPosition:UITableViewScrollPositionNone];
            }
        }
        self.selectedIndexPath = indexPath;
    }
}

- (void)deselectRowAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated{
    if([self isValidIndexPath:indexPath]){
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        self.selectedIndexPath = nil;
    }
}

@end
