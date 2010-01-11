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
	UIImage *image;
	UIImageView *imageView;
	NSString *label;
	id<IFCellModel> model;
	NSString *key;
}

- (id)initWithImage:(UIImage *)newImage withLabel:(NSString *)newLabel atKey:(NSString *)newKey inModel:(id<IFCellModel>)newModel;
- (void)setNewImage:(UIImage *)newImage;

@end
