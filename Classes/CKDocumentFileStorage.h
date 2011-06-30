//
//  CKDocumentFileStorage.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKDocumentStorage.h"


/** TODO
 */
@interface CKDocumentFileStorage : NSObject<CKDocumentStorage> {
	NSString* _path;
}

@property (nonatomic,retain) NSString* path;

- (id)initWithPath:(NSString*)path;

- (BOOL)load:(CKDocumentCollection*)collection;
- (BOOL)save:(CKDocumentCollection*)collection;
- (BOOL)deleteFile;

@end
