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
#import "CKUIImageView+Style.h"
#import "CKUIViewController+Style.h"
#import "CKUITableView+Style.h"


@interface CKStyleManager : NSObject {
	NSMutableDictionary* _styles;
}

@property (nonatomic,retain) NSMutableDictionary* styles;

+ (CKStyleManager*)defaultManager;

- (void)setStyle:(NSMutableDictionary*)style forKey:(NSString*)key;
- (NSMutableDictionary*)styleForObject:(id)object  propertyName:(NSString*)propertyName;

//Could extend to load style from files ...
- (void)loadContentOfFileNamed:(NSString*)name;
- (void)loadContentOfFile:(NSString*)path;

@end
