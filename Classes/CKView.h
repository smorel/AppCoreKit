//
//  CKNibViewController.h
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


@class CKView;

typedef UIView*(^CKViewCreationBlock)();
typedef void(^CKViewSetupBlock)(UIView* view,id model, CKView* ownerView);

@interface CKViewTemplate : NSObject{
	CKViewCreationBlock viewCreationBlock;
	CKViewSetupBlock viewSetupBlock;
}

@property (nonatomic, copy) CKViewCreationBlock viewCreationBlock;
@property (nonatomic, copy) CKViewSetupBlock viewSetupBlock;

@end


@interface CKView : UIView {
	CKViewTemplate* viewTemplate;
	NSMutableArray* internal;
	UIView* subView;
}

@property (nonatomic, retain) CKViewTemplate *viewTemplate;
@property (nonatomic, retain, readonly) NSMutableArray *internal;

- (void)bind:(id)object;
- (void)unbind;
- (void)addObject:(id)object;

@end


@interface UIView (Snapshot)
- (UIImage*)snapshot;
@end