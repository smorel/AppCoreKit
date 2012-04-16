//
//  CKItemViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObject.h"
#import "CKCallback.h"
#import "CKWeakRef.h"


/** TODO
 */
enum{
	CKItemViewFlagNone = 1UL << 0,
	CKItemViewFlagSelectable = 1UL << 1,
	CKItemViewFlagEditable = 1UL << 2,
	CKItemViewFlagRemovable = 1UL << 3,
	CKItemViewFlagMovable = 1UL << 4,
	CKItemViewFlagAll = CKItemViewFlagSelectable | CKItemViewFlagEditable | CKItemViewFlagRemovable | CKItemViewFlagMovable
};
typedef NSUInteger CKItemViewFlags;


@class CKItemViewContainerController;

/** TODO
 */
@interface CKItemViewController : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, copy, readonly) NSIndexPath *indexPath;
@property (nonatomic, assign, readonly) CKItemViewContainerController* containerController;

@property (nonatomic, retain) id value;
@property (nonatomic, assign) UIView *view;

@property (nonatomic, assign) CKItemViewFlags flags;
@property (nonatomic, assign) CGSize size;

//TODO : REPLACE BY BLOCKS !

@property (nonatomic, retain) CKCallback* createCallback;
@property (nonatomic, retain) CKCallback* initCallback;
@property (nonatomic, retain) CKCallback* setupCallback;
@property (nonatomic, retain) CKCallback* selectionCallback;
@property (nonatomic, retain) CKCallback* accessorySelectionCallback;
@property (nonatomic, retain) CKCallback* becomeFirstResponderCallback;
@property (nonatomic, retain) CKCallback* resignFirstResponderCallback;
@property (nonatomic, retain) CKCallback* viewDidAppearCallback;
@property (nonatomic, retain) CKCallback* viewDidDisappearCallback;

//Used on CKTableViewCellControllers only yet
@property (nonatomic, retain) CKCallback* layoutCallback;


//Private for subclassing

- (NSString*)identifier;

- (void)setupView:(UIView *)view;
- (void)rotateView:(UIView*)view animated:(BOOL)animated;

- (void)applyStyle;

- (void)viewDidAppear:(UIView *)view;
- (void)viewDidDisappear;

- (NSIndexPath *)willSelect;
- (void)didSelect;
- (void)didSelectAccessoryView;

- (void)initView:(UIView*)view;
- (void)didBecomeFirstResponder;
- (void)didResignFirstResponder;

- (UIView *)loadView;
- (void)postInit;

@end
