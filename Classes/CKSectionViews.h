//
//  CKSectionViews.h
//  CloudKit
//
//  Created by Martin Dufort on 12-05-31.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKStyleView.h"
#import "CKTableViewController.h"

@interface CKSectionHeaderView : CKStyleView
@property(nonatomic,copy) NSString* text;
@property(nonatomic,retain,readonly) UILabel* label;
@property(nonatomic,assign,readonly) CKTableViewController* tableViewController;
@property(nonatomic,assign) UIEdgeInsets contentInsets;
@end

@interface CKSectionFooterView : CKSectionHeaderView
@end
