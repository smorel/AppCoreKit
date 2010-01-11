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
	UIImageView *_imageView;
	NSString *_label;
	id<IFCellModel> _model;
	NSString *_key;
}

@property (retain, readwrite) UIImage *image;

- (id)initWithImage:(UIImage *)image withLabel:(NSString *)label atKey:(NSString *)key inModel:(id<IFCellModel>)model;

@end
