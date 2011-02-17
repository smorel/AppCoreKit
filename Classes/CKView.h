//
//  CKNibViewController.h
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewDataBinder.h"
#import "CKUIControlActionBlockBinder.h"


typedef UIView*(^CKViewCreationBlock)();
typedef NSMutableArray*(^CKViewSetupBlock)(UIView* view,id mordel);

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

- (void)bind:(id)object;
- (void)unbind;
- (UIImage*)snapshot;

@end
