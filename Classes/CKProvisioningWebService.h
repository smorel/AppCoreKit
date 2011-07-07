//
//  CKProvisioningWebService.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-05.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKWebService2.h"
#import "CKModelObject.h"

/** 
 TODO
 */
@interface CKProductRelease : CKModelObject{}
@property (nonatomic,copy) NSString* bundleIdentifier;
@property (nonatomic,copy) NSString* applicationName;
@property (nonatomic,copy) NSDate* releaseDate;
@property (nonatomic,copy) NSString* buildVersion;
@property (nonatomic,copy) NSString* releaseNotes;
@property (nonatomic,copy) NSURL* releaseNotesURL;
@property (nonatomic,copy) NSURL* provisioningURL;
@property (nonatomic,assign) BOOL recommended;
@end

/** 
 TODO
 */
@interface CKProvisioningWebService : CKWebService2{
}

/** 
 This method checks if their is a newer version on the provisioning server compared to the currently running version identified by bundleIdentifier and version.
 
 @param bundleIdentifier : TODO
 @param version :  TODO
 @param completion :  TODO
 @param failure :  TODO
 */
- (void)checkForNewProductReleaseWithBundleIdentifier:(NSString*)bundleIdentifier version:(NSString*)version 
                                    completion:(void (^)(BOOL upToDate,NSString* version))completion 
                                       failure:(void (^)(NSError* error))failure;

/** 
 This method lists all the released products hosted by the provisioning server.
 
 @param bundleIdentifier : TODO
 @param completion : TODO
 @param failure : TODO
 */
- (void)listAllProductReleasesWithBundleIdentifier:(NSString*)bundleIdentifier
                                 completion:(void (^)(NSArray* productReleases))completion 
                                    failure:(void (^)(NSError* error))failure;

/** 
 This method retrieves the details for a specific released version hosted on the provisioning server.
 
 @param version : TODO
 @param bundleIdentifier : TODO
 @param completion : TODO
 @param failure : TODO
 */
- (void)detailsForProductReleaseWithBundleIdentifier:(NSString*)bundleIdentifier version:(NSString*)version
               completion:(void (^)(CKProductRelease* productRelease))completion 
                  failure:(void (^)(NSError* error))failure;

@end
