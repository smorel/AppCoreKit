//
//  CKLicense.mm
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKLicense.h"
#import <VendorsKit/VendorsKit.h>
#include <string>
#include <vector>
#include <algorithm>
#include <iostream>
#include <fstream>

@implementation CKLicense
@end

#ifdef DISTRIBUTION
#pragma message( "Compiling CKLicense by enabling License check." ) 

static const char pub_key[] = {"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyjapahE9WLWaumlDcPJJ\nyql1xeMF3IZh123wFLW0E6K5Twgbg7aFzCnZCLj4j6n606m7OWWKNCHEAGO/68e4\nGRL+k2237iCLeDc4cGv94sENiBcJbt0lVTiLZbS8j7P/v58Cc83bXlRIwmKHyS4C\n1JnSeAPLsEbblKsgkEyX/xEgQYK8G2hhpdotMtKM2ltlvSE2PBSSE+61qxRaBQHy\nkgW3JUA9uDcxwXCRLT7AzC8MNqQk89pCPFEk6sgHslrFjQEIj54vEJBbDsbHnjON\n9wE6zAG23H/3i/zmmgWn/ueHmxGkxMbEFmKn8YllUZ3vDA1hffjyxsYv47qhtSye\nkQIDAQAB\n-----END PUBLIC KEY-----"};

void dumpLicense(std::vector<std::string> params){
    int i =0;
    for(std::vector<std::string>::iterator it = params.begin(); it != params.end(); ++it, ++i){
        if(i != 5){
            printf("AppCoreKit License : %s\n",(*it).c_str());
        }
    }
}

bool checkLicense(){
    @autoreleasepool {
        printf("Checking AppCoreKit License.\n");
        
        Class delegateClass = [CKLicense class];
        if([delegateClass respondsToSelector:@selector(licenseKey)]){
            NSString* licenseKey = [delegateClass performSelector:@selector(licenseKey)];
            if([licenseKey length] <= 0){
                printf("AppCoreKit : Invalid license length.\n");
                exit(0);
            }else{
                unsigned char* decodedLicense = decodeBase64UsingPublicRSAKey([licenseKey UTF8String],pub_key);
                if(decodedLicense){
                    std::string str((char*)decodedLicense);
                    std::vector<std::string> strings;
                    
                    int pos = 0;
                    while(pos >= 0 && pos < str.length()){
                        int oldPos = pos;
                        pos = str.find('*', oldPos);
                        
                        int length = pos - oldPos;
                        std::string s = str.substr(oldPos,length);
                        strings.push_back(s);
                        
                        if(pos > 0){
                            ++pos;
                        }
                    }
                    
                    if(strings[0].compare("AppCoreKit") != 0){
                        printf("AppCoreKit : Invalid license format.\n");
                        exit(0);
                    }
                    
                    NSTimeInterval interval = atof(strings[2].c_str());
                    if(interval > 0){
                        CFDateRef aCFDate = CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent());
                        NSTimeInterval currentInterval = CFDateGetAbsoluteTime(aCFDate) + NSTimeIntervalSince1970;
                        
                        NSTimeInterval diff = interval - currentInterval;
                        if(diff < 0){
                            printf("AppCoreKit : Your license has expired.\n");
                            exit(0);
                        }
                    }
                    
                    std::string bundleId = strings[1];
                    if(bundleId.length() > 0){
                        std::transform(bundleId.begin(), bundleId.end(),bundleId.begin(), ::tolower);
                        std::string appId = [[[[NSBundle mainBundle] bundleIdentifier]lowercaseString]UTF8String];
                        if(bundleId.compare(appId) != 0){
                            printf("AppCoreKit : Invalid license for bundleId '%s'.\n",appId.c_str());
                            exit(0);
                        }
                    }
                    
                    dumpLicense(strings);
                    
                    free(decodedLicense);
                }else{
                    printf("AppCoreKit : Invalid license format.\n");
                    exit(0);
                }
            }
        }else{
            printf("AppCoreKit : You must return your AppCoreKit license key by adding the following code in one of your .m files :\n\n@implementation CKLicense(YourAppName)\n\n+ (NSString*)licenseKey{\n\t return @\"YourLicenseKey\";\n}\n\n@end ");
            exit(0);
        }
    }
    
    return true;
}

#else

#pragma message( "Compiling CKLicense by bypassing License check." )

bool checkLicense(){
    @autoreleasepool {
        printf("Bypassing AppCoreKit License Check.\n");
    }
    return true;
}

#endif


static bool bo_checkLicense = checkLicense();