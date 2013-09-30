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
#import "CKVersion.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface CKConfiguration()
@property(nonatomic,assign,readwrite) CKConfigurationType type;

- (void)updateConfig;
@end

 

@implementation CKConfiguration
@synthesize type,inlineDebuggerEnabled,checkViewControllerCopyInBlocks,assertForBindingsOutOfContext,usingARC;

- (id)init{
    self = [super init];
    
    [self updateConfig];
    
    return self;
}

- (void)reloadAfterFileUpdate{
    [super reloadAfterFileUpdate];
    [self updateConfig];
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
    
    if([CKOSVersion() floatValue] >= 5){
        self.checkViewControllerCopyInBlocks = NO;
    }
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
