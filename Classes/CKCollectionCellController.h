//
//  CKCollectionCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-23.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStandardCellController.h"

//SEB TODO adds accessors in dictionary helper with special keys
/*
@interface CKCollectionCellControllerStyle : CKTableViewCellControllerStyle{
}

@property (nonatomic, copy) NSString* noItemsMessage;
@property (nonatomic, copy) NSString* oneItemMessage;
@property (nonatomic, copy) NSString* manyItemsMessage;
@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, assign) UIActivityIndicatorViewStyle indicatorStyle;

+ (CKCollectionCellControllerStyle*)defaultStyle;

@end
*/


/** TODO
 */
@interface CKCollectionCellController : CKTableViewCellController {
	UILabel* _label;
	UIActivityIndicatorView* _activityIndicator;
}

@property (nonatomic,retain,readonly) UILabel* label;
@property (nonatomic,retain,readonly) UIActivityIndicatorView* activityIndicator;

@end
