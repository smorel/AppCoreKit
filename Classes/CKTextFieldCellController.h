//
//  CKTextFieldCellController.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStandardCellController.h"


/** TODO
 */
@interface CKTextFieldCellController : CKStandardCellController <UITextFieldDelegate> {
	NSString *_placeholder;

	BOOL _secureTextEntry;
}

@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

- (id)initWithTitle:(NSString *)title value:(NSString *)value placeholder:(NSString *)placeholder;

@end
