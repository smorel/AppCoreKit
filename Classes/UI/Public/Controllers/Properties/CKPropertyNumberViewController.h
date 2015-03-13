//
//  CKPropertyNumberViewController.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-13.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertyStringViewController.h"


/** CKPropertyBoolViewController propvides the logic to edit and synchronize changes to/from a NSNumber or native numeric types property with the desired degree of customization.
 
 @see CKPropertyStringViewController for more informations.
 */
@interface CKPropertyNumberViewController : CKPropertyStringViewController

@end


/** Property extended attributes that operates with CKPropertyNumberViewController
 */
@interface CKPropertyExtendedAttributes (CKPropertyNumberViewController)

/**
 */
@property (nonatomic, retain) NSNumber* placeholderValue;

@end