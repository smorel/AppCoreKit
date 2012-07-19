//
//  CKMultiFloatPropertyCellController.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyTableViewCellController.h"


/**
 */
@interface CKMultiFloatPropertyCellController: CKPropertyTableViewCellController<UITextFieldDelegate> {
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
