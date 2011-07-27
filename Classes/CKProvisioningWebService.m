//
//  CKProvisioningWebService.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-05.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKProvisioningWebService.h"
#import "CKMapping.h"
#import "CKNSObject+Invocation.h"
#import "CKNSString+URIQuery.h"
#import "CKNSDate+Conversions.h"

@implementation CKProductRelease
@synthesize bundleIdentifier,applicationName,releaseDate,buildNumber,versionNumber,releaseNotes,releaseNotesURL,provisioningURL,recommended;

- (void)releaseDateMetaData:(CKModelObjectPropertyMetaData*)metaData{
    metaData.dateFormat = @"dd-MM-yy HH:mm:ss";
}

@end


static NSMutableDictionary* CKProvisioningProductMappings = nil;
@interface CKProvisioningWebService ()
- (NSMutableDictionary*)productReleaseMapping;
@end


@implementation CKProvisioningWebService

- (id)init {
	[super init];
    self.baseURL = [NSURL URLWithString:@"http://10.0.1.100/v1/app/"];
    return self;
}

- (NSMutableDictionary*)productReleaseMapping{
    if(CKProvisioningProductMappings == nil){
        NSMutableDictionary* mappings = [NSMutableDictionary dictionary];
        [mappings mapStringForKeyPath:@"bundle-identifier"  toKeyPath:@"bundleIdentifier"   required:YES];
        [mappings mapStringForKeyPath:@"name"               toKeyPath:@"applicationName"    required:YES];
        [mappings mapStringForKeyPath:@"build-number"	    toKeyPath:@"buildNumber"	    required:YES];
        [mappings mapStringForKeyPath:@"version-number"	    toKeyPath:@"versionNumber"      required:YES];
        [mappings mapStringForKeyPath:@"release-notes-text" toKeyPath:@"releaseNotes"       required:YES];
        [mappings mapURLForKeyPath:   @"release-notes-url"  toKeyPath:@"releaseNotesURL"    required:NO];
        [mappings mapKeyPath:         @"releaseDate"    withValueFromBlock:^id(id sourceObject, NSError **error) {
            NSString* dateStr = [sourceObject objectForKey:@"release-date"];
            
            NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
            formatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
            formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDate* date = [formatter dateFromString:dateStr];

            return date;
        }];
        [mappings mapKeyPath:         @"provisioningURL"    withValueFromBlock:^id(id sourceObject, NSError **error) {
            NSString* urlStr = [sourceObject objectForKey:@"ota-url"];
            return [NSURL URLWithString:urlStr];
            //NSURL* url = [NSURL URLWithString:[urlStr decodeAllPercentEscapes]];
            //return url;
        }];
        [mappings mapKeyPath:         @"recommended"        withValueFromBlock:^id(id sourceObject, NSError **error) {
            NSNumber* recommendedNumber = [sourceObject objectForKey:@"recommended"];
            BOOL recommended = [recommendedNumber boolValue];
            return [NSNumber numberWithBool:recommended];
        }];
        CKProvisioningProductMappings = [mappings retain];
    }
    return CKProvisioningProductMappings;
}

- (void)checkForNewProductReleaseWithBundleIdentifier:(NSString*)bundleIdentifier version:(NSString*)version 
                                           completion:(void (^)(BOOL upToDate,NSString* version))completion 
                                              failure:(void (^)(NSError* error))failure{
    CKWebRequest2* request = [self getRequestForPath:@"check.json" params:[NSDictionary dictionaryWithObjectsAndKeys:bundleIdentifier,@"bundle-identifier",version,@"build-number",nil]];
    request.successBlock = ^(id value){
        NSNumber* upToDateNumber = [value objectForKey:@"uptodate"];
        BOOL upToDate = [upToDateNumber boolValue];
        NSString* buildVersion = [value objectForKey:@"latest-build"];
        if(completion){
            completion(upToDate,buildVersion);
        }
    };
    request.failureBlock = ^(NSError* error){
        if(failure){
            failure(error);
        }
    };
    
    [self performRequest:request];
}


- (void)listAllProductReleasesWithBundleIdentifier:(NSString*)bundleIdentifier
                                        completion:(void (^)(NSArray* productReleases))completion 
                                           failure:(void (^)(NSError* error))failure{
    CKWebRequest2* request = [self getRequestForPath:@"list.json" params:[NSDictionary dictionaryWithObjectsAndKeys:bundleIdentifier,@"bundle-identifier",nil]];
    request.transformBlock = ^(id value){
        NSMutableArray* releases = [NSMutableArray array];
        NSError* error;
        for(NSDictionary* dico in [value objectForKey:@"releases"]){
            CKProductRelease* release = [[[CKProductRelease alloc]initWithDictionary:dico withMappings:[self productReleaseMapping] error:&error]autorelease];
            [releases addObject:release];
        }
        return (id)releases;
    };
    request.successBlock = ^(id value){
        if(completion){
            completion((NSArray*)value);
        }
    };
    request.failureBlock = ^(NSError* error){
        if(failure){
            failure(error);
        }
    };
    
    [self performRequest:request];
}

- (void)detailsForProductReleaseWithBundleIdentifier:(NSString*)bundleIdentifier version:(NSString*)version
                      completion:(void (^)(CKProductRelease* productRelease))completion 
                         failure:(void (^)(NSError* error))failure{
    CKWebRequest2* request = [self getRequestForPath:@"descriptor.json" params:[NSDictionary dictionaryWithObjectsAndKeys:bundleIdentifier,@"bundle-identifier",version,@"build-number",nil]];
    request.transformBlock = ^(id value){
        NSError* error;
        CKProductRelease* release = [[[CKProductRelease alloc]initWithDictionary:value withMappings:[self productReleaseMapping] error:&error]autorelease];
        return (id)release;
    };
    request.successBlock = ^(id value){
        if(completion){
            completion((CKProductRelease*)value);
        }
    };
    request.failureBlock = ^(NSError* error){
        if(failure){
            failure(error);
        }

    };
    
    [self performRequest:request];
}

- (CKWebSource *)sourceForReleasesWithBundleIdentifier:(NSString *)bundleIdentifier {
	__block CKProvisioningWebService *bself = self;

	CKWebSource *source = [[[CKWebSource alloc] init] autorelease];
	source.requestBlock = ^(NSRange range) {
		return (CKWebRequest2 *)[bself getRequestForPath:@"list.json" params:[NSDictionary dictionaryWithObjectsAndKeys:bundleIdentifier,@"bundle-identifier",nil]];
	};
	source.transformBlock = ^(id value){
		NSMutableArray* releases = [NSMutableArray array];
		NSError* error;
		for(NSDictionary* dico in [value objectForKey:@"releases"]){
			CKProductRelease* release = [[[CKProductRelease alloc]initWithDictionary:dico withMappings:[self productReleaseMapping] error:&error]autorelease];
			[releases addObject:release];
		}
		return (id)releases;
	};

	return source;
}

@end
