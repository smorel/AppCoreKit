//
//  CKStandardCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-06-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"


@interface CKStandardCellController : CKTableViewCellController {
	UITableViewCellStyle _style;
	NSString *_text;
	NSString *_detailedText;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *detailedText;

- (id)initWithStyle:(UITableViewCellStyle)style;
- (id)initWithText:(NSString *)text;

@end
