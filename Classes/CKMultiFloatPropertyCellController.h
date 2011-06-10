//
//  CKMultiFloatPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <CKTableViewCellController.h>


@interface CKMultiFloatPropertyCellController: CKTableViewCellController<UITextFieldDelegate> {
	id _multiFloatValue;
	NSMutableDictionary* _textFields;
	NSMutableDictionary* _labels;
}

@property(nonatomic,retain)id multiFloatValue;
@property(nonatomic,retain)NSMutableDictionary* textFields;
@property(nonatomic,retain)NSMutableDictionary* labels;

//private
-(void)valueChanged;

@end
