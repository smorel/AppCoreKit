//
//  CKStyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyles.h"
#import "CKUIView+Style.h"
#import "CKTableViewCellController+Style.h"
#import "CKUILabel+Style.h"
#import "CKUIViewController+Style.h"


@interface CKStyleManager : NSObject {
	NSMutableDictionary* _styles;
	NSMutableSet* _loadedFiles;
}

+ (CKStyleManager*)defaultManager;

- (NSMutableDictionary*)styleForObject:(id)object  propertyName:(NSString*)propertyName;

//Could extend to load style from files ...
- (void)loadContentOfFileNamed:(NSString*)name;
- (void)loadContentOfFile:(NSString*)path;

//private
- (void)importContentOfFileNamed:(NSString*)name;
- (void)importContentOfFile:(NSString*)path;

@end
