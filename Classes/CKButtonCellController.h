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
	NSString *_label;
}

- (id)initWithLabel:(NSString *)label withAction:(SEL)action onTarget:(id)target;

@end
