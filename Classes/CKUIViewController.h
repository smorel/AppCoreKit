//
//  CKUIViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^CKUIViewControllerAnimatedBlock)(UIViewController* controller,BOOL animated);
typedef void(^CKUIViewControllerBlock)(UIViewController* controller);

/** TODO
 */
@interface CKUIViewController : UIViewController {
	NSString* _name;
}

@property (nonatomic,retain) NSString* name;

@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewWillAppearBlock;
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewDidAppearBlock;
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewWillDisappearBlock;
@property (nonatomic,copy) CKUIViewControllerAnimatedBlock viewDidDisappearBlock;
@property (nonatomic,copy) CKUIViewControllerBlock viewDidLoadBlock;
@property (nonatomic,copy) CKUIViewControllerBlock viewDidUnloadBlock;

/** 
 This method is called upon initialization. Subclasses can override this method.
 @warning You should not call this method directly.
 */
- (void)postInit;

@end
