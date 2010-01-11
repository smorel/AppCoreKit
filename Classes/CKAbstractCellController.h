//
//  CKBasicCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 09-12-15.
//  Copyright 2009 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFCellController.h"
#import "IFCellModel.h"

@interface CKAbstractCellController : NSObject <IFCellController> {
	id _target;
	SEL _action;
	
	BOOL _selectable;
}

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, getter=isSelectable) BOOL selectable;

- (UITableViewCell *)tableView:(UITableView *)tableView cellWithStyle:(UITableViewStyle)newStyle;

@end
