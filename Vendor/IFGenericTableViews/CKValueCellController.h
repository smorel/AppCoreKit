//
//  CKValueCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKAbstractCellController.h"


@interface CKValueCellController : CKAbstractCellController {
	UITableViewCellStyle style;
	NSString *label;
	id<IFCellModel> model;
	NSString *key;
}

- (id)initWithStyle:(UITableViewCellStyle)newStyle withLabel:(NSString *)newLabel atKey:(NSString *)newKey inModel:(id<IFCellModel>)newModel;

@end
