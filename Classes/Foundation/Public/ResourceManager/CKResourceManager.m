//
//  CKResourceManager.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-07-17.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CKResourceManager.h"
#import "NSObject+Invocation.h"


NSString* CKResourceManagerFileDidUpdateNotification = @"RMResourceManagerFileDidUpdateNotification";
NSString* CKResourceManagerApplicationBundlePathKey  = @"RMResourceManagerApplicationBundlePathKey";
NSString* CKResourceManagerRelativePathKey           = @"RMResourceManagerRelativePathKey";
NSString* CKResourceManagerMostRecentPathKey         = @"RMResourceManagerMostRecentPathKey";

NSString* CKResourceManagerDidEndUpdatingResourcesNotification = @"RMResourceManagerDidEndUpdatingResourcesNotification";
NSString* CKResourceManagerUpdatedResourcesPathKey             = @"RMResourceManagerUpdatedResourcesPathKey";

@implementation CKResourceManager


+ (BOOL)isResourceManagerConnected{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]isResourceManagerConnected];
    }
    return NO;
}

+ (Class)resourceManagerClass{
    static NSInteger kIsResourceManagerFrameworkAvailable = -1;
    static Class kResourceManagerClass = nil;
    if(kIsResourceManagerFrameworkAvailable == -1){
        kResourceManagerClass = NSClassFromString(@"RMResourceManager");
        kIsResourceManagerFrameworkAvailable = (kResourceManagerClass != nil);
    }
    return kResourceManagerClass;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathForResource:name ofType:ext];
    }
    
    return [[NSBundle mainBundle]pathForResource:name ofType:ext];
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext observer:(id)observer usingBlock:(void(^)(id observer, NSString* path))updateBlock{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathForResource:name ofType:ext observer:observer usingBlock:updateBlock];
    }
    
    return [[NSBundle mainBundle]pathForResource:name ofType:ext];
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext];
    }
    return [[NSBundle mainBundle]pathsForResourcesOfType:ext inDirectory:nil];
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext localization:(NSString *)localizationName{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext localization:localizationName];
    }
    return [[NSBundle mainBundle]pathsForResourcesOfType:ext inDirectory:nil forLocalization:localizationName];
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext observer:(id)observer usingBlock:(void(^)(id observer, NSArray* paths))updateBlock{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext observer:observer usingBlock:updateBlock];
    }
    return [[NSBundle mainBundle]pathsForResourcesOfType:ext inDirectory:nil];
}

+ (NSArray *)pathsForResourcesWithExtension:(NSString *)ext localization:(NSString *)localizationName observer:(id)observer usingBlock:(void(^)(id observer, NSArray* paths))updateBlock{
    if([self resourceManagerClass]){
        return [[self resourceManagerClass]pathsForResourcesWithExtension:ext localization:localizationName observer:observer usingBlock:updateBlock];
    }
    return [[NSBundle mainBundle]pathsForResourcesOfType:ext inDirectory:nil forLocalization:localizationName];
}

+ (void)addObserverForResourcesWithExtension:(NSString*)ext object:(id)object usingBlock:(void(^)(id observer, NSArray* paths))updateBlock{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]addObserverForResourcesWithExtension:ext object:object usingBlock:updateBlock];
    }
}

+ (void)addObserverForPath:(NSString*)path object:(id)object usingBlock:(void(^)(id observer, NSString* path))updateBlock{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]addObserverForPath:path object:object usingBlock:updateBlock];
    }
}

+ (void)removeObserver:(id)object{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]removeObserver:object];
    }
}

+ (UIImage*)imageNamed:(NSString*)name{
    if([self resourceManagerClass]){
        NSString* path = [[UIImage class]performSelector:@selector(resoucePathForImageNamed:) withObject:name];
        return path ? [UIImage imageWithContentsOfFile:path] : nil;
    }
    return [UIImage imageNamed:name];
}

+ (UIImage*)imageNamed:(NSString*)name update:(void(^)(UIImage* image))update{
    if([self resourceManagerClass]){
        NSString* path = [[UIImage class]performSelector:@selector(resoucePathForImageNamed:) withObject:name];
        return  path ? [[UIImage class]performSelector:@selector(imageWithContentsOfFile:update:) withObject:path withObject:update] : nil;
    }
    return [UIImage imageNamed:name];
}

+ (NSString*)pathForImageNamed:(NSString*)name{
    if([self resourceManagerClass]){
        NSString* path = [[UIImage class]performSelector:@selector(resoucePathForImageNamed:) withObject:name];
        return path;
    }
    
    NSLog(@"You should not use the method [CKResourceManager pathForImageNamed] without the ResourceManager framework linked to your app or it will return nil !!!");
    
    return nil;
}

+ (void)setHudTitle:(NSString*)title{
    if([self resourceManagerClass]){
        [[self resourceManagerClass]setHudTitle:title];
    }
}

@end
