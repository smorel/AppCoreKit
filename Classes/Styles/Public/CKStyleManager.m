//
//  CKStyleManager.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleManager.h"
#import "UIView+Style.h"
#import "CKResourceManager.h"
#import "NSObject+Singleton.h"
#import "CKWeakRef.h"

NSString* CKStyleManagerDidReloadNotification = @"CKStyleManagerDidReloadNotification";

@interface CKStyleManagerCache : NSObject
@property(nonatomic,retain) NSMutableDictionary* cache;

- (CKStyleManager*)styleManagerWithContentOfFileNamed:(NSString*)fileName;

@end

static CKStyleManager* CKStyleManagerDefault = nil;
static NSInteger kLogEnabled = -1;

@implementation CKStyleManager

+ (CKStyleManager*)defaultManager{
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CKStyleManagerDefault = [[CKStyleManager alloc]init];
    });
    
	return CKStyleManagerDefault;
}


+ (CKStyleManager*)styleManagerWithContentOfFileNamed:(NSString*)fileName{
    return [[CKStyleManagerCache sharedInstance]styleManagerWithContentOfFileNamed:fileName];
}

- (void)registerOnDependencies:(NSSet*)dependencies{
    __block CKStyleManager* bself = self;
    for(NSString* path in dependencies){
        [CKResourceManager addObserverForPath:path object:bself usingBlock:^(id observer, NSString *path) {
            [bself reloadAfterFileUpdate];
        }];
    }
}


- (void)reloadAfterDelay{
    static dispatch_queue_t reloadQueue = nil;
    if(!reloadQueue){
        reloadQueue = dispatch_queue_create("com.wherecloud.CKStyleManager.reload", 0);
    }
    
    [CKResourceManager setHudTitle:@"Reloading Stylesheets..."];
    dispatch_async(reloadQueue, ^{
        
        [super reloadAfterFileUpdate];
        [CKResourceManager setHudTitle:nil];
        
        //Using self here to retain it until the the task finishes its execution
        [self performSelectorOnMainThread:@selector(notifyStyleManagerDidReload) withObject:nil waitUntilDone:NO];
    });
    
}

- (void)notifyStyleManagerDidReload{
    [[NSNotificationCenter defaultCenter]postNotificationName:CKStyleManagerDidReloadNotification object:self];
}

- (void)reloadAfterFileUpdate{
    //If multiple requests for reloading stylesheets occurs in batch like
    //images and several style files have been updated, we delay the effective reload to avoid
    //doing it several times
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAfterDelay) object:nil];
    [self performSelector:@selector(reloadAfterDelay) withObject:nil afterDelay:.2];
}

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
	return [self dictionaryForObject:object propertyName:propertyName];
}

- (void)loadContentOfFileNamed:(NSString*)name{
    static BOOL hasDebuggerStyleBeenLoaded = NO;
    if(!hasDebuggerStyleBeenLoaded){
        hasDebuggerStyleBeenLoaded = YES;
        [self loadContentOfFileNamed:@"CKInlineDebugger"];//Imports debugger stylesheet first.
    }
    
	NSString* path = [CKResourceManager pathForResource:name ofType:@"style"];
   // NSLog(@"loadContentOfFileNamed %@ with path %@",name,path);
	[self loadContentOfFile:path];
}


- (BOOL)importContentOfFileNamed:(NSString*)name{
    
	NSString* path = [CKResourceManager pathForResource:name ofType:@"style"];
    //NSLog(@"loadContentOfFileNamed %@ with path %@",name,path);
	return [self appendContentOfFile:path];
}

+ (BOOL)logEnabled{
    if(kLogEnabled < 0){
        BOOL bo = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CKDebugStyle"]boolValue];
        kLogEnabled = bo;
    }
    return kLogEnabled;
}

- (BOOL)isEmpty{
    return [self.tree count] <= 0;
}

@end


@implementation NSMutableDictionary (CKStyleManager)

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
    return [self dictionaryForObject:object propertyName:propertyName];
}

@end


@implementation NSObject (CKStyleManager)

- (NSMutableDictionary*)stylesheet{
    return [self appliedStyle];
}

- (void)findAndApplyStyleFromStylesheet:(NSMutableDictionary*)parentStylesheet  propertyName:(NSString*)propertyName{
    if(!parentStylesheet)
        return;
    
    NSMutableDictionary* style = [parentStylesheet styleForObject:self propertyName:propertyName];
    if([self isKindOfClass:[UIView class]]){
        [[self class] applyStyle:style toView:(UIView*)self appliedStack:[NSMutableSet set] delegate:nil];
    }else{
        [self applyStyle:style];
    }
}

@end


@implementation CKStyleManagerCache

- (void)dealloc{
    [_cache release];
    [super dealloc];
}

- (CKStyleManager*)styleManagerWithContentOfFileNamed:(NSString*)fileName{
    CKWeakRef* styleManagerRef = [self.cache objectForKey:fileName];
    if(styleManagerRef){
        return styleManagerRef.object;
    }
    
    if(!self.cache){
        self.cache = [NSMutableDictionary dictionary];
    }
    
    CKStyleManager* manager = [[[CKStyleManager alloc]init]autorelease];
    [manager loadContentOfFileNamed:fileName];
    
    styleManagerRef = [CKWeakRef weakRefWithObject:manager block:^(CKWeakRef *weakRef) {
        [self.cache removeObjectForKey:fileName];
    }];
    
    [self.cache setObject:styleManagerRef forKey:fileName];
    
    return manager;
}

@end