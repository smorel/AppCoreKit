//
//  CKLocalization.m
//  AppCoreKit
//
//  Created by Olivier Collet.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKLocalization.h"
#import "CKLocalizationManager_Private.h"
#import "CKResourceFileUpdateManager.h"
#import "NSObject+Singleton.h"
#import "CKCascadingTree.h"
#import "CKConfiguration.h"

#import "CKResourceManager.h"

NSString *CKLocalizationCurrentLocalization(void) {
	NSArray *l18n = [[NSBundle mainBundle] preferredLocalizations];
	return [l18n objectAtIndex:0];
}

static NSMutableArray* kLocalizationStringTableNames = nil;
static NSString* kLastLocalization = nil;

void CKResetLanguageFileCache(){
    [kLocalizationStringTableNames release];
    kLocalizationStringTableNames = nil;
}

void rebuildLocalizationTablesForLocalization(NSArray* stringsPaths){
    
    NSMutableArray* files = [NSMutableArray arrayWithCapacity:stringsPaths.count];
    for(NSString* stringsPath in stringsPaths){
        NSString* fileName = [stringsPath lastPathComponent];
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
    
    kLocalizationStringTableNames = [files retain];
}

void createTemporaryLocalizationBundle(NSArray* stringsPaths){
    NSString *tempPath = NSTemporaryDirectory();
    tempPath = [tempPath stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    for (NSString *path in stringsPaths) {
        NSURL* URL = [NSURL fileURLWithPath:path];
        
        NSString *localizationPath = [tempPath stringByAppendingPathComponent:URL.path.stringByDeletingLastPathComponent.lastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:localizationPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *lastPath = [localizationPath stringByAppendingPathComponent:URL.lastPathComponent];
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:lastPath error:nil];
    }
    
    [[CKLocalizationManager sharedManager] reloadBundleAtPath:tempPath];
}

void updateUI(){
    [[CKLocalizationManager sharedManager]setNeedsLiveUpdateRefresh : YES];
    [CKResourceManager reloadUI];
    [[CKLocalizationManager sharedManager]performSelector:@selector(setNeedsLiveUpdateRefresh:) withObject:@(NO) afterDelay:2];
}

NSString* CKGetLocalizedString(NSString* localization,NSString* key,NSString* value){
    //Init resource manager updates
    if(kLocalizationStringTableNames == nil){
        [CKResourceManager addObserverForResourcesWithExtension:@"strings" object:@"CKGetLocalizedString" usingBlock:^(id observer, NSArray* paths){
            rebuildLocalizationTablesForLocalization(paths);
            createTemporaryLocalizationBundle(paths);
            updateUI();
        }];
    }
    
    
    //Find all localization tables
    if(kLastLocalization != localization || kLocalizationStringTableNames == nil){
        kLastLocalization = localization;
        
        NSArray* stringsURLs = [CKResourceManager pathsForResourcesWithExtension:@"strings" localization:kLastLocalization];
        rebuildLocalizationTablesForLocalization(stringsURLs);
        createTemporaryLocalizationBundle(stringsURLs);//necessary if we already have files in cache from dropbox
        
        /*if([[CKConfiguration sharedInstance]resourcesLiveUpdateEnabled]){
            NSMutableArray *newStringsURL = [NSMutableArray arrayWithCapacity:stringsURLs.count];
            for (NSURL *filePathURL in stringsURLs) {
                NSString *localPath = [[CKResourceFileUpdateManager sharedInstance] registerFileWithProjectPath:filePathURL.path handleUpdate:^(NSString *localPath) {
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
                    
                    [CKResourceManager reloadUI];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CKCascadingTreeFilesDidUpdateNotification object:nil];
                }];
                
                [newStringsURL addObject:[NSURL fileURLWithPath:localPath]];
            }
            
            stringsURLs = newStringsURL;
        }*/
        
    }
    
    for(NSString* tableName in kLocalizationStringTableNames){
        NSString* result =  [[[CKLocalizationManager sharedManager]localizedBundle] localizedStringForKey:key value:value table:tableName];
        if(![result isEqualToString:key])
            return result;
    }
    return value;
}

CKLocalizedString* CKLocalizedStringWithString(NSString* string){
    if([string isKindOfClass:[CKLocalizedString class]]){
        return (CKLocalizedString*)string;
    }
    return [[[CKLocalizedString alloc]initWithLocalizedKey:string]autorelease];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
UIImage* CKLocalizedImageNamed(NSString* name){
    if ([[UIScreen mainScreen] scale] == 2) {
        if (![[name pathExtension] isEqualToString:@""]) {
            NSString *pathExtension = [name pathExtension];
            name = [[[name stringByDeletingPathExtension] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:pathExtension];
        }
        else
            name = [name stringByAppendingString:@"@2x"];
    }
    
    NSBundle* localizedBundle = [[CKLocalizationManager sharedManager]localizedBundle];
    
    NSURL *imageURL = [localizedBundle URLForResource:[name stringByDeletingPathExtension] withExtension:[name pathExtension]];
    if (!imageURL)
        imageURL = [localizedBundle URLForResource:[name stringByDeletingPathExtension] withExtension:@"png"];
    if (!imageURL)
        imageURL = [localizedBundle URLForResource:[name stringByDeletingPathExtension] withExtension:nil];
    
    
    if (!imageURL)
        imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:[name pathExtension]];
    if (!imageURL)
        imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:@"png"];
    if (!imageURL)
        imageURL = [[NSBundle mainBundle] URLForResource:[name stringByDeletingPathExtension] withExtension:nil];
    
    if (imageURL == nil)
        return nil;
    
    UIImage *image = [[[UIImage alloc] initWithContentsOfFile:imageURL.path] autorelease];
    return image;
}
#pragma clang diagnostic pop
