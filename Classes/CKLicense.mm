//
//  CKLicense.mm
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKLicense.h"
#import <VendorsKit/VendorsKit.h>
#include <string.h>

#import "NSDate+Conversions.h"


@implementation CKLicense
@end

#ifdef DISTRIBUTION

static const char pub_key[] = {"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyjapahE9WLWaumlDcPJJ\nyql1xeMF3IZh123wFLW0E6K5Twgbg7aFzCnZCLj4j6n606m7OWWKNCHEAGO/68e4\nGRL+k2237iCLeDc4cGv94sENiBcJbt0lVTiLZbS8j7P/v58Cc83bXlRIwmKHyS4C\n1JnSeAPLsEbblKsgkEyX/xEgQYK8G2hhpdotMtKM2ltlvSE2PBSSE+61qxRaBQHy\nkgW3JUA9uDcxwXCRLT7AzC8MNqQk89pCPFEk6sgHslrFjQEIj54vEJBbDsbHnjON\n9wE6zAG23H/3i/zmmgWn/ueHmxGkxMbEFmKn8YllUZ3vDA1hffjyxsYv47qhtSye\nkQIDAQAB\n-----END PUBLIC KEY-----"};

bool checkLicense(){
    Class delegateClass = [CKLicense class];
    if([delegateClass respondsToSelector:@selector(licenseKey)]){
        NSString* licenseKey = [delegateClass performSelector:@selector(licenseKey)];
        if([licenseKey length] <= 0){
            printf("AppCoreKit : Invalid license key");
            exit(0);
        }else{
            unsigned char* str = decodeBase64UsingPublicRSAKey([licenseKey UTF8String],pub_key);
            if(str){
                NSError* error = nil;
                id dico = [[JSONDecoder decoderWithParseOptions:JKParseOptionValidFlags]parseUTF8String:str length:strlen((char*)str) error:&error];
                if(error){
                    printf("AppCoreKit : Invalid license format.");
                    exit(0);
                }
                
                NSString* product = [[dico objectForKey:@"product"]lowercaseString];
                if(![product isEqualToString:@"appcorekit"]){
                    printf("AppCoreKit : Invalid license key product.");
                    exit(0);
                }
                
                NSTimeInterval interval = [[dico objectForKey:@"exp_date"]doubleValue];
                if(interval > 0){
                    NSTimeInterval currentInterval = [[NSDate date]timeIntervalSince1970];
                    
                    NSTimeInterval diff = interval - currentInterval;
                    if(diff < 0){
                        printf("AppCoreKit : Your license has expired.");
                        exit(0);
                    }
                }
                
                free(str);
            }else{
                printf("AppCoreKit : Invalid license key");
                exit(0);
            }
        }
    }else{
        printf("AppCoreKit : You must return your AppCoreKit license key By adding the following code in one of your .m files :\n\n@implementation CKLicense(YourAppName)\n\n+ (NSString*)licenseKey{\n\t return @\"YourLicenseKey\";\n}\n\n@end ");
        exit(0);
    }
    
    return true;
}

static bool bo_checkLicense = checkLicense();


#endif