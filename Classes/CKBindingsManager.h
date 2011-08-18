//
//  CKBindingsManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-03-11.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"


/** TODO
 */
@interface CKBindingsManager : NSObject {
	NSMutableDictionary* _bindingsForContext;
	NSMutableDictionary* _bindingsPoolForClass;
	
	NSMutableSet* _contexts;
}

+ (CKBindingsManager*)defaultManager;

- (id)dequeueReusableBindingWithClass:(Class)bindingClass;
- (void)bind:(CKBinding*)binding withContext:(id)context;
- (void)unbind:(CKBinding*)binding;
- (void)unregister:(CKBinding*)binding;
- (void)unbindAllBindingsWithContext:(id)context;

@end
