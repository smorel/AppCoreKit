//
//  CKLicense.mm
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKLicense.h"

@implementation CKLicense
@end

#ifdef DISTRIBUTION

bool checkLicense(){
    Class delegateClass = [CKLicense class];
    if([delegateClass respondsToSelector:@selector(licenseKey)]){
        NSString* licenseKey = [delegateClass performSelector:@selector(licenseKey)];
        if([licenseKey length] <= 0){
            printf("AppCoreKit : Invalid license key");
            exit(0);
        }
    }else{
        printf("AppCoreKit : You must return your AppCoreKit license key By adding the following code in one of your .m files :\n\n@implementation CKLicense(YourAppName)\n\n+ (NSString*)licenseKey{\n\t return @\"YourLicenseKey\";\n}\n\n@end ");
        exit(0);
    }
    return true;
}

static bool bo_checkLicense = checkLicense();


#endif