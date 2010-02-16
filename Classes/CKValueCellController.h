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
	UITableViewCellStyle _style;
	NSString *_text;
	id _value;
}

- (id)initWithStyle:(UITableViewCellStyle)style text:(NSString *)text value:(id)value;

- (id)initWithStyle:(UITableViewCellStyle)style withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model DEPRECATED_ATTRIBUTE;

@end
