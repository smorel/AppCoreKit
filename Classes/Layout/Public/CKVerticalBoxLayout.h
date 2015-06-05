//
//  CKVerticalBoxLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBoxProtocol.h"
#import "CKLayoutBox.h"

/** CKVerticalBoxLayout layouts children layoutBoxes vertically.
 */
@interface CKVerticalBoxLayout : CKLayoutBox

@end



@interface CKVerticalBoxLayout(CKLayout_Deprecated)

/** default value is YES. Opposite of flexibleSize.
 */
@property(nonatomic,assign) BOOL sizeToFitLayoutBoxes;


@end