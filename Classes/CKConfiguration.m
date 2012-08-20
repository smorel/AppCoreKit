//
//  CKConfiguration.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "CKConfiguration.h"
#import "CKCascadingTree.h"
#import "NSValueTransformer+Additions.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface CKConfiguration()
@property(nonatomic,assign,readwrite) CKConfigurationType type;
@property(nonatomic,retain,readwrite) NSString* sourceTreeDirectory;
@property(nonatomic,assign,readwrite) BOOL resourcesLiveUpdateEnabled;

- (void)updateConfig;
@end



@implementation CKConfiguration
@synthesize type,inlineDebuggerEnabled,checkViewControllerCopyInBlocks,assertForBindingsOutOfContext,sourceTreeDirectory,resourcesLiveUpdateEnabled;

- (id)init{
    self = [super init];
    
    [self updateConfig];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConfig) name:CKCascadingTreeFilesDidUpdateNotification object:nil];
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CKCascadingTreeFilesDidUpdateNotification object:nil];
	[super dealloc];
}

+ (BOOL)isSimulator{
    static NSString* platform = nil;
    if(!platform){
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = (char *)malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        platform = [[NSString stringWithUTF8String:machine]retain];
        free(machine);
    }
    return [platform hasPrefix:@"x86"];
}

- (void)updateConfig{
#ifdef DEBUG
    //Support for old plist configuration
    self.assertForBindingsOutOfContext = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CKDebugAssertForBindingsOutOfContext"]boolValue];
    self.checkViewControllerCopyInBlocks = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CKDebugCheckForBlockCopy"]boolValue];
    self.inlineDebuggerEnabled = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CKInlineDebuggerEnabled"]boolValue];
#endif
    
    NSMutableDictionary* dico = nil;
    switch(self.type){
        case CKConfigurationTypeDebug:   dico = [self dictionaryForKey:@"@debug"]; break;
        case CKConfigurationTypeRelease: dico = [self dictionaryForKey:@"@release"]; break;
    }
    
    if(dico){
        [NSValueTransformer transform:dico toObject:self];
    }
    
    BOOL simu = [CKConfiguration isSimulator];
    self.sourceTreeDirectory = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SRC_ROOT"];//[[[NSProcessInfo processInfo] environment] objectForKey:@"SRC_ROOT"];
    self.resourcesLiveUpdateEnabled = simu && self.sourceTreeDirectory != nil;
}

+ (CKConfiguration*)initWithContentOfFileNames:(NSString*)fileName type:(CKConfigurationType)type{
	NSString* path = [[NSBundle mainBundle]pathForResource:fileName ofType:@"conf"];
    
    CKConfiguration* instance = [[[CKConfiguration alloc]initWithContentOfFile:path]autorelease];
    instance.type = type;
    [instance updateConfig];
    
    [CKConfiguration setSharedInstance:instance];
    return instance;
}

@end
