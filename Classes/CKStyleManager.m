//
//  CKStyleManager.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleManager.h"
#import "UIView+Style.h"

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

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
	return [self dictionaryForObject:object propertyName:propertyName];
}

- (void)loadContentOfFileNamed:(NSString*)name{
    static BOOL hasDebuggerStyleBeenLoaded = NO;
    if(!hasDebuggerStyleBeenLoaded){
        hasDebuggerStyleBeenLoaded = YES;
        [self loadContentOfFileNamed:@"CKInlineDebugger"];//Imports debugger stylesheet first.
    }
    
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
   // NSLog(@"loadContentOfFileNamed %@ with path %@",name,path);
	[self loadContentOfFile:path];
}


- (BOOL)importContentOfFileNamed:(NSString*)name{
    
	NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:@"style"];
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
#if !TARGET_IPHONE_SIMULATOR
    return [self appliedStyle];
#else
    return [self debugAppliedStyle];
#endif
}

- (void)findAndApplyStyleFromStylesheet:(NSMutableDictionary*)parentStylesheet  propertyName:(NSString*)propertyName{
    NSMutableDictionary* style = parentStylesheet ? [parentStylesheet styleForObject:self propertyName:propertyName] : [[CKStyleManager defaultManager]styleForObject:self propertyName:propertyName];
    if([self isKindOfClass:[UIView class]]){
        [[self class] applyStyle:style toView:(UIView*)self appliedStack:[NSMutableSet set] delegate:nil];
    }else{
        [self applyStyle:style];
    }
}

@end