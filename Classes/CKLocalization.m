//
//  CKLocalization.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKLocalization.h"

NSString *CKLocalizationCurrentLocalization(void) {
	NSArray *l18n = [[NSBundle mainBundle] preferredLocalizations];
	return [l18n objectAtIndex:0];
}

NSMutableArray* CKLocalizationStringTableNames = nil;

NSString* CKGetLocalizedString(NSBundle* bundle,NSString* key,NSString* value){
    //Find all localization tables
    if(CKLocalizationStringTableNames == nil){
        NSMutableArray* files = [[NSMutableArray alloc]init];
        NSArray* stringsURLs = [bundle URLsForResourcesWithExtension:@"strings" subdirectory:nil];
        for(NSURL* stringsURL in stringsURLs){
            NSString* fileName = [[stringsURL absoluteString]lastPathComponent];
            NSRange range = [fileName rangeOfString:@"."];
            if(range.location != NSNotFound){
                NSString* file = [fileName substringToIndex:range.location];
                //priority to application table
                if([file isEqualToString:@"Localizable"]){
                    [files insertObject:file atIndex:0];
                }
                [files addObject:file];
            }
        }
        CKLocalizationStringTableNames = files;
    }
    
    for(NSString* tableName in CKLocalizationStringTableNames){
        NSString* result =  [bundle localizedStringForKey:key value:value table:tableName];
        if(![result isEqualToString:key])
            return result;
    }
    return value;
}

