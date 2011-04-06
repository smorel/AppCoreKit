//
//  CKViewTemplateManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-02.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//
#import "CKView.h"

#define CKDeclareViewTemplateForClass(modelClass,viewTemplateClass)\
      [CKViewTemplateManager registerViewTemplateForClass:[modelClass class] viewTemplate:[[[viewTemplateClass alloc]init]autorelease]];

@interface CKViewTemplateManager : NSObject {
	NSMutableDictionary* templates;
}


+ (CKViewTemplateManager*)manager;
+ (BOOL)registerViewTemplateForClass:(Class)class viewTemplate:(CKViewTemplate*)viewTemplate;
+ (BOOL)registerViewTemplateForKey:(NSString*)key viewTemplate:(CKViewTemplate*)viewTemplate;
+ (CKViewTemplate*)viewTemplateForObject:(id)object;
+ (CKViewTemplate*)viewTemplateForClass:(Class)class;
+ (CKViewTemplate*)viewTemplateForKey:(NSString*)key;

@end
