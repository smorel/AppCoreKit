//
//  CKMultiFloatPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyGridCellController.h"


/** TODO
 */
@interface CKMultiFloatPropertyCellController: CKPropertyGridCellController<UITextFieldDelegate> {
	id _multiFloatValue;
	NSMutableDictionary* _textFields;
	NSMutableDictionary* _labels;
	NSMutableDictionary* _namelabels;
}

@property(nonatomic,retain)id multiFloatValue;

//private
- (void)valueChanged;
- (void)propertyChanged;
- (void)rebind;

@end
