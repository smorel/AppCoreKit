//
//  CKUIViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** TODO
 */
@interface CKUIViewController : UIViewController {
	NSString* _name;
}

@property (nonatomic,retain) NSString* name;

/** 
 This method is called upon initialization. Subclasses can override this method.
 @warning You should not call this method directly.
 */
- (void)postInit;

@end
