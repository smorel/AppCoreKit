//
//  CKButtonCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-01-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKAbstractCellController.h"


@interface CKButtonCellController : CKAbstractCellController {
	NSString *label;
}

- (id)initWithLabel:(NSString *)newLabel withAction:(SEL)newAction onTarget:(id)newTarget;

@end
