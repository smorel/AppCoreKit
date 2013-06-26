//
//  UIView+CKLayout.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-06-26.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKLayoutBoxProtocol.h"
#import "CKLayoutBox.h"

/**
 */
@interface UIView (CKLayout)<CKLayoutBoxProtocol>

/** Default value is YES. that means layoutting the view will automatically shrink or expand its size to fit the layouted content.
 Views managed by UIViewController or UITableViewCellContentView are forced to NO as the controller, container controller or table view cell controller is responsible to manage it's view frame.
 */
@property(nonatomic,assign) BOOL sizeToFitLayoutBoxes;

@end