//
//  CKResourceFileUpdateManager.h
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    This requieres to have a key defined in your application main bundle.
    And that you defined 
    "SRC_ROOT" = <STRING> "$SRCROOT"
 */
@interface CKResourceFileUpdateManager : NSObject

- (NSString*)registerFileWithProjectPath:(NSString*)path handleUpdate:(void (^)(NSString* localPath))updateHandle;
- (void)unregisterFileWithProjectPath:(NSString*)path;

@end
