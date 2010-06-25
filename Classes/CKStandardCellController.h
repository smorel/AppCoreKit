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

	UIColor *_backgroundColor;
	UIColor *_textColor;
	UIColor *_detailedTextColor;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *detailedText;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *detailedTextColor;

- (id)initWithStyle:(UITableViewCellStyle)style;
- (id)initWithText:(NSString *)text;

@end
