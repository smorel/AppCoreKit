//
//  CKHorizontalBoxLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBoxProtocol.h"
#import "CKLayoutBox.h"

/** CKHorizontalBoxLayout layouts children layoutBoxes horizontally.
 */
@interface CKHorizontalBoxLayout : CKLayoutBox

/** default value is NO
 */
@property(nonatomic,assign) BOOL flexibleSize;

@end


@interface CKHorizontalBoxLayout(CKLayout_Deprecated)

/** default value is YES. Opposite of flexibleSize.
 */
@property(nonatomic,assign) BOOL sizeToFitLayoutBoxes;


@end