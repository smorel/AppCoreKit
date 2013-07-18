//
//  CKTabViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTabViewController.h"
#import "UIViewController+Style.h"
#import "CKStyleManager.h"
#import <QuartzCore/QuartzCore.h>
#import "CKRuntime.h"
#import "CKPropertyExtendedAttributes+Attributes.h"
#import "NSObject+Bindings.h"
#import <objc/runtime.h>
#import "CKDebug.h"
#import "UIView+Positioning.h"
#import "UIView+Style.h"

//CKTabViewItem
@interface CKTabViewItem()
@property(nonatomic,assign,readwrite)CKTabViewItemPosition position;
@end


#define kCKTabViewDefaultHeight 49

@implementation CKTabView

@synthesize delegate = _delegate;
@synthesize items = _items;
@synthesize selectedIndex = _selectedIndex;
@synthesize style;
@synthesize itemsSpace;
@synthesize selectedTabIndicatorView = _selectedTabIndicatorView;
@synthesize contentInsets;

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKTabViewStyle", 
                                               CKTabViewStyleFill,
                                               CKTabViewStyleCenter);
}

- (void)postInit {
	self.backgroundColor = [UIColor blackColor];
    self.style = CKTabViewStyleFill;
    self.itemsSpace = 0;
    self.contentInsets = UIEdgeInsetsZero;
}

- (id)initWithFrame:(CGRect)frame {
	frame.size.height = kCKTabViewDefaultHeight;	// Forces the height to the same as a UITabBar
    self = [super initWithFrame:frame];
    if (self) {
		[self postInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, kCKTabViewDefaultHeight);	// Defaults to the same as a UITabBar
		[self postInit];
    }
    return self;
}

- (void)dealloc {
    [_selectedTabIndicatorView release];
    [_items release]; _items = nil;
    [super dealloc];
}

#pragma mark - Layout

- (void)setSelectedTabIndicatorView:(UIView *)theselectedTabIndicatorView{
    [_selectedTabIndicatorView removeFromSuperview];
    [_selectedTabIndicatorView release];
    _selectedTabIndicatorView = [theselectedTabIndicatorView retain];
    [self addSubview:_selectedTabIndicatorView];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
    CGFloat viewWidth = self.bounds.size.width - (contentInsets.left + contentInsets.right);
    CGFloat viewHeight = self.bounds.size.height - (contentInsets.top + contentInsets.bottom);
    
    switch(self.style){
        case CKTabViewStyleFill:{
            CGFloat width = (viewWidth - (([_items count] - 1) * self.itemsSpace)) / [_items count];
            CGFloat x = floorf(contentInsets.left);
            for (CKTabViewItem *item in _items) {
                item.frame = CGRectMake(x, contentInsets.top, width, viewHeight);
                x += floorf(width + self.itemsSpace);
            }
            break;
        }
        case CKTabViewStyleCenter:{
            CGFloat totalWidth = 0;
            for (CKTabViewItem *item in _items) {
                totalWidth += item.frame.size.width;
            }
            totalWidth += ([_items count] - 1) * self.itemsSpace;
            
            CGFloat x = floorf(contentInsets.left + (viewWidth / 2.0) - (totalWidth / 2.0));
            for (CKTabViewItem *item in _items) {
             //   [item sizeToFit];
                CGFloat y = floorf(contentInsets.top + (viewHeight / 2.0) - (item.frame.size.height / 2.0));
                item.frame = CGRectMake(x,y,item.frame.size.width,item.frame.size.height);
                x += floorf(item.frame.size.width + self.itemsSpace);
            }
            
            break;
        }
        case CKTabViewStyleAlignLeft:{
            CGFloat x = floorf(contentInsets.left);
            for (CKTabViewItem *item in _items) {
              //  [item sizeToFit];
                CGFloat y = floorf(contentInsets.top + (viewHeight / 2.0) - (item.frame.size.height / 2.0));
                item.frame = CGRectMake(x,y,item.frame.size.width,item.frame.size.height);
                x += floorf(item.frame.size.width + self.itemsSpace);
            }
            
            break;
        }
        case CKTabViewStyleAlignRight:{
            CGFloat x = floorf(contentInsets.left + viewWidth);
            for (CKTabViewItem *item in _items) {
              //  [item sizeToFit];
                x -= floorf(item.frame.size.width);
                CGFloat y = floorf(contentInsets.top + (viewHeight / 2.0) - (item.frame.size.height / 2.0));
                item.frame = CGRectMake(x,y,item.frame.size.width,item.frame.size.height);
                x -= floorf(self.itemsSpace);
            }
            
            break;
        }
    }
    
    if(_selectedTabIndicatorView && (_selectedIndex < [_items count])){
        CGSize size = _selectedTabIndicatorView.frame.size;
        
        CKTabViewItem* selectedItem = [_items objectAtIndex:_selectedIndex];
        CGFloat itemCenter = selectedItem.frame.origin.x + selectedItem.frame.size.width / 2.0;
        
        _selectedTabIndicatorView.frame = CGRectMake(itemCenter - size.width / 2.0,0,size.width,size.height);
    }
}

#pragma mark - Item Management

// Add the items

- (void)setItems:(NSArray *)items {
    
	// Remove the previous items
	for (CKTabViewItem *item in _items) {
        [item removeTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[item removeFromSuperview];
	}
	[_items release];
    
	// Add the new items
	_items = [items copy];
    
    
    NSMutableDictionary* tabBarStyle = [self stylesheet];
    
	int index = 0;
	for (CKTabViewItem *item in _items) {
		CKAssert([item isKindOfClass:[CKTabViewItem class]], @"Items must be of class CKTabViewItem.");
        
        if([_items count] == 1){
            item.position = CKTabViewItemPositionAlone;
        }
        else if(index == 0){
            item.position = CKTabViewItemPositionFirst;
        }else if(index == _items.count - 1){
            item.position = CKTabViewItemPositionLast;
        }else{
            item.position = CKTabViewItemPositionMiddle;
        }
        
        NSMutableDictionary* itemStyle = [tabBarStyle styleForObject:item  propertyName:nil];
        [[item class] applyStyle:itemStyle toView:item appliedStack:[NSMutableSet set] delegate:nil];
        [item sizeToFit];
        
        item.width += item.titleEdgeInsets.left + item.titleEdgeInsets.right;
        
        [item addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:item];
		[(CKTabViewItem *)item setSelected:(index++ == _selectedIndex)];
	}
    
    [self layoutSubviews];
}

// Handle item selection

- (void)buttonClicked:(id)sender {
	UIView *item = (UIView*)sender;
	if ([item isKindOfClass:[CKTabViewItem class]] == NO) {
		return;
	}
    
	NSUInteger index = [_items indexOfObject:item];
	if (index < [_items count]) {
		CKTabViewItem *currentSelectedItem = [_items objectAtIndex:_selectedIndex];
		[currentSelectedItem setSelected:NO];
		[(CKTabViewItem *)item setSelected:YES];
        
		if ([self.delegate respondsToSelector:@selector(tabView:didSelectItemAtIndex:)]) {
			[self.delegate tabView:self didSelectItemAtIndex:index];
		}
		_selectedIndex = index;
	}
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSUInteger)index{
    if(_selectedIndex != index){
        CKTabViewItem *currentSelectedItem = [_items objectAtIndex:_selectedIndex];
		[currentSelectedItem setSelected:NO];
        CKTabViewItem *newSelectedItem = [_items objectAtIndex:index];
		[newSelectedItem setSelected:YES];
        _selectedIndex = index;
    }
}

@end


@implementation CKTabViewItem
@synthesize position;

+ (void)load{
    CKSwizzleSelector([UIViewController class],@selector(dealloc), @selector(CKTabViewItem_UIViewController_dealloc));
}

- (void)positionExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKTabViewItemPosition", 
                                                 CKTabViewItemPositionFirst,
                                                 CKTabViewItemPositionMiddle,
                                                 CKTabViewItemPositionLast,
                                                 CKTabViewItemPositionAlone);
}

- (void)dealloc{
    [self clearBindingsContext];
    [super dealloc];
}

@end

//CKTabViewController

@interface CKTabViewController ()

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain, readwrite) CKTabView *tabBar;

- (void)updateTabBarItems;

@end

//

@implementation CKTabViewController

@synthesize tabBar = _tabBar;
@synthesize style = _style;
@synthesize willSelectViewControllerBlock = _willSelectViewControllerBlock;
@synthesize didSelectViewControllerBlock = _didSelectViewControllerBlock;
@dynamic containerView;

- (void)postInit{
    [super postInit];
    self.style = CKTabViewControllerStyleBottom;
}

- (void)dealloc {
    [_tabBar setDelegate : nil];
    [_tabBar release]; 
    _tabBar = nil;
    [_willSelectViewControllerBlock release]; 
    _willSelectViewControllerBlock = nil;
    [_didSelectViewControllerBlock release]; 
    _didSelectViewControllerBlock = nil;
    [super dealloc];
}

- (void)loadView {
	[super loadView];

    if(!_tabBar){
        self.tabBar = [[[CKTabView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height - kCKTabViewDefaultHeight,self.view.bounds.size.width,kCKTabViewDefaultHeight)]autorelease];
        self.tabBar.delegate = self;
        self.tabBar.clipsToBounds = YES;
        [self.view addSubview:self.tabBar];
    }
    
	[self updateTabBarItems];
}

- (void)styleExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKTabViewControllerStyle",
                                                 CKTabViewControllerStyleBottom,
                                                 CKTabViewControllerStyleTop);
}

- (void)setStyle:(CKTabViewControllerStyle)theStyle{
    _style = theStyle;
    switch(theStyle){
        case CKTabViewControllerStyleBottom:{
            if(_tabBar){
                CGRect frame = CGRectMake(0,self.view.bounds.size.height - _tabBar.frame.size.height,
                                          self.view.bounds.size.width,_tabBar.frame.size.height);
                _tabBar.frame = frame;
                _tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            }
            if(self.containerView){
                CGRect frame = CGRectMake(0,0,self.view.bounds.size.width,
                                          self.view.bounds.size.height - _tabBar.frame.size.height);
                self.containerView.frame = frame;
                self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            }
            break;
        }
        case CKTabViewControllerStyleTop:{
            if(_tabBar){
                CGRect frame = CGRectMake(0,0,self.view.bounds.size.width,_tabBar.frame.size.height);
                _tabBar.frame = frame;
                _tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            }
            
            if(self.containerView){
                CGRect frame = CGRectMake(0,_tabBar.frame.size.height,
                                          self.view.bounds.size.width,
                                          self.view.bounds.size.height - _tabBar.frame.size.height);
                self.containerView.frame = frame;
                self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            }

            break;
        }
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [_tabBar setDelegate : nil];
	self.tabBar = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    CKViewControllerAnimatedBlock appearEndBlock = [self.viewWillAppearEndBlock copy];
    self.viewWillAppearEndBlock = nil;
    
    //disable animations 
    [CATransaction begin];
    [CATransaction 
     setValue: [NSNumber numberWithBool: YES]
     forKey: kCATransactionDisableActions];
    
	[super viewWillAppear:animated];
    
    [self setStyle:self.style];//Apply layout ...
    
    NSMutableDictionary* controllerStyle = [self.styleManager styleForObject:self  propertyName:nil];
	NSMutableDictionary* tabBarStyle = [controllerStyle styleForObject:self  propertyName:@"tabBar"];
    for(CKTabViewItem* item in self.tabBar.items){
        NSMutableDictionary* itemStyle = [tabBarStyle styleForObject:item  propertyName:nil];
        [[item class] applyStyle:itemStyle toView:item appliedStack:[NSMutableSet set] delegate:nil];
        [item sizeToFit];
    }
    
    [CATransaction commit];
    
    if(appearEndBlock){
        appearEndBlock(self,animated);
        self.viewWillAppearEndBlock = [appearEndBlock autorelease];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
	[super setViewControllers:viewControllers];
	[self updateTabBarItems];
}

- (void)updateTabBarItems {
	if (self.viewControllers) {
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
        
      //  NSMutableDictionary* controllerStyle = [self.styleManager styleForObject:self  propertyName:nil];
      //  NSMutableDictionary* tabBarStyle = [controllerStyle styleForObject:self  propertyName:@"tabBar"];
        
        int i =0;
		for (UIViewController *vc in self.viewControllers) {
            CKTabViewItem* item = vc.tabViewItem;
            
            if([self.viewControllers count] == 1){
                item.position = CKTabViewItemPositionAlone;
            }
            else if(i == 0){
                item.position = CKTabViewItemPositionFirst;
            }else if(i == [self.viewControllers count] - 1){
                item.position = CKTabViewItemPositionLast;
            }else{
                item.position = CKTabViewItemPositionMiddle;
            }
            
            /*
            if(self.isViewDisplayed){
                NSMutableDictionary* itemStyle = [tabBarStyle styleForObject:item  propertyName:nil];
                [[item class] applyStyle:itemStyle toView:item appliedStack:[NSMutableSet set] delegate:nil];
                [item sizeToFit];
            }*/

			[items addObject:item];
            ++i;
		}
		[self.tabBar setItems:items];
	}
}

#pragma mark - CKTabViewDelegate

- (void)tabView:(CKTabView *)tabView didSelectItemAtIndex:(NSUInteger)index {
    if(_willSelectViewControllerBlock){
        _willSelectViewControllerBlock(self,index);
    }
	[self presentViewControllerAtIndex:index withTransition:CKTransitionNone];
    if(_didSelectViewControllerBlock){
        _didSelectViewControllerBlock(self,index);
    }
}


- (void)presentViewControllerAtIndex:(NSUInteger)index withTransition:(CKTransitionType)transition {
    [super presentViewControllerAtIndex:index withTransition:transition];
    if(_tabBar){
        _tabBar.selectedIndex = self.selectedIndex;
    }
}


-(void)setSelectedIndex:(NSUInteger)selectedIndex{
    [super setSelectedIndex:selectedIndex];
    [[self tabBar]setSelectedIndex:selectedIndex];
}

@end


#pragma mark - UIViewController Additions

@implementation UIViewController (CKTabViewItem)

static char CKViewControllerTabViewItemKey;

- (void)CKTabViewItem_UIViewController_dealloc{
    id item = objc_getAssociatedObject(self, &CKViewControllerTabViewItemKey);
    if(item){
        [item clearBindingsContext];
    }
    [self CKTabViewItem_UIViewController_dealloc];
}

- (void)setTabViewItem:(CKTabViewItem *)tabViewItem {
    objc_setAssociatedObject(self, 
                             &CKViewControllerTabViewItemKey,
                             tabViewItem,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CKTabViewItem *)tabViewItem {
    id item = objc_getAssociatedObject(self, &CKViewControllerTabViewItemKey);
	if (item) return item;
	
	CKTabViewItem *newItem = [[[CKTabViewItem alloc] initWithFrame:CGRectZero] autorelease];
    newItem.contentEdgeInsets = UIEdgeInsetsMake(3, 10, 3, 10);
	newItem.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	[newItem setTitle:self.title forState:UIControlStateNormal];
	[newItem setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
	[newItem setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
   // [newItem sizeToFit];
    newItem.bounds = CGRectMake(0, 0, newItem.bounds.size.width + (self.title ? 10 : 0), newItem.bounds.size.height + (self.title ? 10 : 0) );
	[self setTabViewItem:newItem];
    
    __block CKTabViewItem* bItem = newItem;
    __block UIViewController* bController = self;
    [newItem beginBindingsContextByRemovingPreviousBindings];
    [self bind:@"title" withBlock:^(id value) {
        [bItem setTitle:bController.title forState:UIControlStateNormal];
        [bItem sizeToFit];
    }];
    [newItem endBindingsContext];
    
	return newItem;
}

@end
