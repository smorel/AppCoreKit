//
//  CKLicense.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <UIKit/UIKit.h>

/** To be able to use AppCoreKit, you must implement the following code in one of your .m files.
 
     @implementation CKLicense(YourAppName)
 
     + (NSString*)licenseKey{
         //Return your license key here.
         return @"";
     }
 
     @end
 */
@interface CKLicense : NSObject
@end