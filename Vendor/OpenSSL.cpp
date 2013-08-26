//
//  OpenSSL.m
//  VendorsKit
//
//  Created by Martin Dufort on 12-08-22.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#include "OpenSSL.h"

#include <string.h>
#include <openssl/rsa.h>
#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/pem.h>

#include <string>

void unbase64(unsigned char *input, int length, unsigned char** output, int* outputLength)
{
    BIO *b64, *bmem;
    
    *output = (unsigned char *)malloc(length+1);
    memset(*output, 0, length+1);
    
    b64 = BIO_new(BIO_f_base64());
    BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
    bmem = BIO_new_mem_buf(input, length);
    bmem = BIO_push(b64, bmem);
    
    *outputLength = BIO_read(bmem, *output, length);
    
    BIO_free_all(bmem);
}


unsigned char* decodeBase64UsingPublicRSAKey(const char* encoded,const char* publicKey){
    unsigned char* decodedLicense = NULL;
    int data_size = 0;
    unbase64((unsigned char *)encoded, strlen(encoded) * sizeof(char),&decodedLicense,&data_size);
    
    unsigned char* destination = NULL;
    
    BIO* bio = BIO_new_mem_buf((void *)publicKey, strlen(publicKey) * sizeof(char));
    if (bio)
    {
        RSA* rsa_key = 0;
        if(PEM_read_bio_RSA_PUBKEY(bio, &rsa_key,NULL,NULL)){
            int returnedRSASize = RSA_size(rsa_key);
            
            destination = new unsigned char[returnedRSASize];
            
            int returnedDigestSize = RSA_public_decrypt(data_size, 
                                                        decodedLicense, destination, rsa_key,
                                                        RSA_PKCS1_PADDING);
            if(returnedDigestSize <=0 ){
                return NULL;
            }
            
            
            destination[returnedDigestSize] = '\0';
            
            //char *errorString = ERR_error_string(ERR_get_error(),0);
            
            RSA_free(rsa_key);
        }/*else{
            char *errorString = ERR_error_string(ERR_get_error(),0);
            printf("OpenSSL : %s",errorString);
        }*/
        
        BIO_free(bio);
    }
    
    return destination;
}