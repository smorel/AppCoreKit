//
//  CKNSNumberPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyGridCellController.h"


/** TODO
 */
@interface CKNSNumberPropertyCellController : CKPropertyGridCellController<UITextFieldDelegate>{	
	UITextField* _textField;
	UISwitch* _toggleSwitch;
}

@property (nonatomic,retain,readonly) UITextField* textField;
@property (nonatomic,retain,readonly) UISwitch* toggleSwitch;

@end
