//
//  CKNSStringPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-01.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyGridCellController.h"


/** TODO
 */
@interface CKNSStringPropertyCellController : CKPropertyGridCellController<UITextFieldDelegate> {
	UITextField* _textField;
}

@property (nonatomic,retain,readonly) UITextField* textField;

@end
