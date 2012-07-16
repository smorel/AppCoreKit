//
//  CKStyleManager.m
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKStyleManager.h"

static CKStyleManager* CKStyleManagerDefault = nil;
static NSInteger kLogEnabled = -1;

@implementation CKStyleManager

+ (CKStyleManager*)defaultManager{
	if(CKStyleManagerDefault == nil){
		CKStyleManagerDefault = [[CKStyleManager alloc]init];
	}
	return CKStyleManagerDefault;
}

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
    if(self.tree == nil || [self.tree isEmpty])
        return nil;
    
	return [self dictionaryForObject:object propertyName:propertyName];
}

- (void)loadContentOfFileNamed:(NSString*)name{
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

@end


@implementation NSMutableDictionary (CKStyleManager)

- (NSMutableDictionary*)styleForObject:(id)object propertyName:(NSString*)propertyName{
    if([[CKStyleManager defaultManager]tree] == nil || [[[CKStyleManager defaultManager]tree]isEmpty])
        return nil;
    
    return [self dictionaryForObject:object propertyName:propertyName];
}

@end