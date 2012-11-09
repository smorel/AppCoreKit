//
//  CKAttributesDictionary.h
//  AppCoreKit
//
//  Created by Fred Brunel.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKItem;


/**
 */
@interface CKAttributesDictionary : NSDictionary {
	CKItem *_item;
	NSDictionary *_attributes;
}

- (id)initWithItem:(CKItem *)item;

@end
