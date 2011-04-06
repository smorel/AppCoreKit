//
//  CKViewTemplateManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-02.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKViewTemplateManager.h"
#import <objc/runtime.h>

@interface CKViewTemplateManager()
@property (nonatomic, retain) NSMutableDictionary *templates;
@end

@implementation CKViewTemplateManager
@synthesize templates;

- (id)init{
	[super init];
	self.templates = [NSMutableDictionary dictionary];
	return self;
}

- (void)dealloc{
	self.templates = nil;
	[super dealloc];
}

+ (BOOL)registerViewTemplateForClass:(Class)class viewTemplate:(CKViewTemplate*)viewTemplate{
	NSString* className = [NSString stringWithUTF8String:class_getName(class)];
	return [self registerViewTemplateForKey:className viewTemplate:viewTemplate];
}

+ (BOOL)registerViewTemplateForKey:(NSString*)key viewTemplate:(CKViewTemplate*)viewTemplate{
	CKViewTemplateManager* manager = [CKViewTemplateManager manager];
	[manager.templates setObject:viewTemplate forKey:key];
	return YES;
}

+ (CKViewTemplate*)viewTemplateForObject:(id)object{
	return [self viewTemplateForClass:[object class]];
}

+ (CKViewTemplate*)viewTemplateForClass:(Class)class{
	NSString* className = [NSString stringWithUTF8String:class_getName(class)];
	return [self viewTemplateForKey:className];
}

+ (CKViewTemplate*)viewTemplateForKey:(NSString*)key{
	CKViewTemplateManager* manager = [CKViewTemplateManager manager];
	return [manager.templates objectForKey:key];
}

+ (CKViewTemplateManager *)manager {
	static CKViewTemplateManager *instance;
	if (instance == nil) {
		instance = [[CKViewTemplateManager alloc] init];
	}
	return instance;
}

@end
