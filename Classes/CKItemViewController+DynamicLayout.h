//
//  CKItemViewController+DynamicLayout.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKItemViewController.h"
#import "CKItemViewControllerFactory.h"


/** TODO : This is used only in CKItemViewControllerFactory to create static view controllers to compute sizes dynamically.
 */
@interface CKItemViewController (CKDynamicLayout)

+ (CKItemViewController*)setupStaticControllerForItem:(CKItemViewControllerFactoryItem*)item
                                             inParams:(NSMutableDictionary*)params 
                                            withStyle:(NSMutableDictionary*)controllerStyle 
                                           withObject:(id)object 
                                        withIndexPath:(NSIndexPath*)indexPath  
                                              forSize:(BOOL)forSize;

@end
