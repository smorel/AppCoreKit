//
//  CKImageResource.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-15.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject.h"


@interface CKImageResource : CKModelObject{
	NSURL* distantURL;
	NSURL* url;
}

@property (nonatomic, retain) NSURL *url;

@end;
