//
//  CKAttributesDictionary.h
//  CloudKit
//
//  Created by Fred Brunel on 10-02-11.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKItem;

@interface CKAttributesDictionary : NSDictionary {
	CKItem *_item;
	NSDictionary *_attributes;
}

- (id)initWithItem:(CKItem *)item;

@end
