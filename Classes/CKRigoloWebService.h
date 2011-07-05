//
//  CKRigoloWebService.h
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
@interface CKRigoloItem : CKModelObject{}
@property (nonatomic,copy) NSString* bundleIdentifier;
@property (nonatomic,copy) NSString* applicationName;
@property (nonatomic,copy) NSDate* releaseDate;
@property (nonatomic,copy) NSString* buildVersion;
@property (nonatomic,copy) NSString* releaseNotes;
@property (nonatomic,copy) NSURL* releaseNotesURL;
@property (nonatomic,copy) NSURL* overTheAirURL;
@end

/** 
 TODO
 */
@interface CKRigoloWebService : CKWebService2{
    id _delegate;
}
@property (nonatomic,assign) id delegate;
- (void)check;
- (void)list;
- (void)detailsForVersion:(NSString*)version;
- (void)updateTo:(CKRigoloItem*)item;
@end

/** 
 TODO
 */
@protocol CKRigoloWebServiceDelegate
@optional
- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService isUpToDateWithVersion:(NSString*)version;
- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService needsUpdateToVersion:(NSString*)version;
- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService didReceiveDetails:(CKRigoloItem*)details;
- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService didReceiveItemList:(NSArray*)rigoloItems;
@end