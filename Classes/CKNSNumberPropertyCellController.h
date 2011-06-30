//
//  CKNSNumberPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStandardCellController.h"


/** TODO
 */
@interface CKNSNumberPropertyCellController : CKStandardCellController<UITextFieldDelegate>{	
	UITextField* _textField;
	UISwitch* _toggleSwitch;
}

@property (nonatomic,retain) UITextField* textField;
@property (nonatomic,retain) UISwitch* toggleSwitch;

@end
