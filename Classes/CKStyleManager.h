//
//  CKStyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCascadingTree.h"


/** TODO
 */
@interface CKStyleManager : CKCascadingTree {
}

+ (CKStyleManager*)defaultManager;

- (NSMutableDictionary*)styleForObject:(id)object  propertyName:(NSString*)propertyName;

- (void)loadContentOfFileNamed:(NSString*)name;
- (BOOL)importContentOfFileNamed:(NSString*)name;

+ (BOOL)logEnabled;

@end

@interface NSMutableDictionary (CKStyleManager)

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName;

@end