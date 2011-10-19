//
//  CKMultiFloatPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
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
@property(nonatomic,retain)NSMutableDictionary* textFields;
@property(nonatomic,retain)NSMutableDictionary* labels;
@property(nonatomic,retain)NSMutableDictionary* namelabels;

//private
-(void)valueChanged;
- (void)rebind;

@end
