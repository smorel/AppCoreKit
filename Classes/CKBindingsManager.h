//
//  CKBindingsManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKBindingsManager : NSObject {
	NSMutableDictionary* _bindingsForContext;
	NSMutableDictionary* _bindingsToContext;
	NSMutableDictionary* _bindingsPoolForClass;
	
	NSMutableSet* _contexts;
}

+ (CKBindingsManager*)defaultManager;

- (id)dequeueReusableBindingWithClass:(Class)bindingClass;
- (void)bind:(id)binding withContext:(id)context;
- (void)unbind:(id)binding withContext:(id)context;
- (void)unbind:(id)binding;
- (void)unbindAllBindingsWithContext:(id)context;

@end
