//
//  CKUrlResource.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-16.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"

@interface CKUrlResource : CKModelObject{
	NSURL* remoteURL;
	NSURL* url;
}

- (BOOL)isRemoteUrl:(NSURL*)theUrl;

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSURL *remoteURL;

@end
