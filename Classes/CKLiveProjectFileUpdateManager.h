//
//  CKLiveUpdateManager.h
//  AppCoreKit
//
//  Created by Guillaume Campagna.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKLiveProjectFileUpdateManager : NSObject

- (NSString*)projectPathOfFileToWatch:(NSString*)path handleUpdate:(void (^)(NSString* localPath))updateHandle;

@end
