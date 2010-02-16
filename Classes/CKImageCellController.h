//
//  CKImageCellController.h
//  CloudKit
//
//  Created by Olivier Collet on 10-01-08.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKAbstractCellController.h"


@interface CKImageCellController : CKAbstractCellController {
	UIImage *_image;
	UIImage *_highlightedImage;
	NSString *_label;
	UITableViewCellAccessoryType _accessoryType;
}

@property (retain, readwrite) UIImage *image;
@property (retain, readwrite) UIImage *highlightedImage;
@property (assign, readwrite) UITableViewCellAccessoryType accessoryType;

- (id)initWithImage:(UIImage *)image title:(NSString *)title;

- (id)initWithImage:(UIImage *)image withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model DEPRECATED_ATTRIBUTE;
- (id)initWithImage:(UIImage *)image highlight:(UIImage *)highlightedImage withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model DEPRECATED_ATTRIBUTE;

@end
