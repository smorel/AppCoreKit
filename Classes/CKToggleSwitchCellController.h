//
//  CKToggleSwitchCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-06-10.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStandardCellController.h"

/** TODO
 */
typedef enum {
	CKToggleSwitchCellStyleSwitch = 0,
	CKToggleSwitchCellStyleCheckmark
} CKToggleSwitchCellStyle;


/** TODO
 */
@interface CKToggleSwitchCellController : CKStandardCellController {
	CKToggleSwitchCellStyle _switchCellStyle;
	BOOL _enabled;
}

@property (nonatomic, assign, getter=isEnabled, setter=enable:) BOOL enabled;

- (id)initWithTitle:(NSString *)title value:(BOOL)value;
- (id)initWithTitle:(NSString *)title value:(BOOL)value style:(CKToggleSwitchCellStyle)style;

@end
