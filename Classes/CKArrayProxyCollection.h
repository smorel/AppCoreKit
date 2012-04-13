//
//  CKArrayProxyCollection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCollection.h"
#import "CKProperty.h"


/** TODO
 */
@interface CKArrayProxyCollection : CKCollection {
	CKProperty* _property;
}

@property (nonatomic,retain) CKProperty* property;

+ (CKArrayProxyCollection*)collectionWithArrayProperty:(CKProperty*)property;

- (id)initWithArrayProperty:(CKProperty*)property;

@end
