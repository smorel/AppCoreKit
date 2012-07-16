//
//  CKImageButtonCellController.h
//  CloudKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKStandardCellController.h"


/** TODO
 */
@interface CKImageButtonCellController : CKStandardCellController {
	UIImage *_highlightedImage;
}

- (id)initWithTitle:(NSString *)title image:(UIImage *)image hightlightedImage:(UIImage *)hightlightedImage;

@end
