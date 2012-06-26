//
//  CKLocalization.m
//  CloudKit
//
//  Created by Olivier Collet on 10-06-15.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKLocalization.h"
#import "CKLocalizationManager_Private.h"
#import "CKLiveProjectFileUpdateManager.h"
#import <CloudKit/CKNSObject+CKSingleton.h>
#import "CKCascadingTree.h"

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
        
#if TARGET_IPHONE_SIMULATOR        
        NSMutableArray *newStringsURL = [NSMutableArray arrayWithCapacity:stringsURLs.count];
        for (NSURL *filePathURL in stringsURLs) {
            NSString *localPath = [[CKLiveProjectFileUpdateManager sharedInstance] projectPathOfFileToWatch:filePathURL.path handleUpdate:^(NSString *localPath) {
                NSString *tempPath = NSTemporaryDirectory();
                tempPath = [tempPath stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                for (NSURL *URL in newStringsURL) {
                    NSString *localizationPath = [tempPath stringByAppendingPathComponent:URL.path.stringByDeletingLastPathComponent.lastPathComponent];
                    [[NSFileManager defaultManager] createDirectoryAtPath:localizationPath withIntermediateDirectories:YES attributes:nil error:nil];
                    
                    NSString *lastPath = [localizationPath stringByAppendingPathComponent:URL.lastPathComponent];
                    [[NSFileManager defaultManager] copyItemAtPath:localPath toPath:lastPath error:nil];
                }
                
                [[CKLocalizationManager sharedManager] reloadBundleAtPath:tempPath];
                
                [[CKLocalizationManager sharedManager] refreshUI];
                [[NSNotificationCenter defaultCenter] postNotificationName:CKCascadingTreeFilesDidUpdateNotification object:nil];
            }];
            
            [newStringsURL addObject:[NSURL fileURLWithPath:localPath]];
        }
        
        stringsURLs = newStringsURL;
#endif
        
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

