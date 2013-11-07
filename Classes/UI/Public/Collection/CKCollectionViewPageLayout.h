//
//  CKCollectionViewPageLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-10-18.
//  Copyright (c) 2013 Sebastien Morel. All rights reserved.
//

#import "CKCollectionViewLayout.h"

/**
 */
@interface CKCollectionViewPageLayout : CKCollectionViewLayout

/**
 */
@property(nonatomic,assign) CGFloat margins;

/**
 */
@property(nonatomic,assign) UIEdgeInsets insets;

/*TODO : adds space between elements & orientation (vertical/horizontal)*/

@end
