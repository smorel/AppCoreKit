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


//http://stackoverflow.com/questions/10451305/rsa-decryption-with-openssl
/*
+(NSString *) rsaDecryptToStringFromText: (NSString *) text
{
    //NSLog(@"text - %@", text);
    
    NSData *decodedData = [NSData dataWithBase64EncodedString: text];
    
    unsigned char* message = (unsigned char*) [decodedData bytes];
    
    NSLog(@"decoded string - %s", message);
    
    RSA *privKey = NULL;
    FILE *priv_key_file;
    unsigned char *ptext;
    
    NSString *keyFilePath = [[NSBundle mainBundle] pathForResource:@"privateKeyPair" ofType:@"pem"];
    
    priv_key_file = fopen([keyFilePath UTF8String], "rb");
    
    ERR_print_errors_fp(priv_key_file);
    
    privKey = PEM_read_RSAPrivateKey(priv_key_file, NULL, NULL, NULL);
    
    int key_size = RSA_size(privKey);
    ptext = malloc(key_size);
    
    int outlen = RSA_private_decrypt(key_size, (const unsigned char*)message, ptext, privKey, RSA_PKCS1_PADDING);
    
    if(outlen < 0) return nil;
    
    RSA_free(privKey);
    
    return [NSString stringWithUTF8String: (const char *)ptext];
}*/



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