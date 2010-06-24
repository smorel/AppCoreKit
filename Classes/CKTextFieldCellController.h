//
//  CKTextFieldCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-06-24.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStandardCellController.h"


@interface CKTextFieldCellController : CKStandardCellController <UITextFieldDelegate> {
	UITextField *_textField;
	NSString *_placeholder;
	CGPoint _tableContentOffset;
}

- (id)initWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder;

@property (nonatomic, readonly, retain) UITextField *textField;

@end
