//
//  CKLayoutFlexibleSpace.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBoxProtocol.h"
#import "CKLayoutBox.h"

/** CKLayoutFlexibleSpace responsability is to pack free space to the maximum. The space is distributed equally between the other items. You can also specify maximum/minimum or fixed size for flexible spaces as well as padding.
 CKLayoutFlexibleSpace Margins as well as margins of the previous/next layoutbox are ignored to get the flexible space fill the empty space to the maximum. This helps to align boxes correctly.
 */
@interface CKLayoutFlexibleSpace : CKLayoutBox
@end