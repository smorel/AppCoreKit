//
//  CKBindingsManager.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKBinding.h"


/**
 */
@interface CKBindingsManager : NSObject {
	NSMutableDictionary* _bindingsForContext;
	NSMutableDictionary* _bindingsPoolForClass;
}

+ (CKBindingsManager*)defaultManager;

- (id)newDequeuedReusableBindingWithClass:(Class)bindingClass;
- (void)bind:(CKBinding*)binding withContext:(id)context;
- (void)unbind:(CKBinding*)binding;
- (void)unregister:(CKBinding*)binding;
- (void)unbindAllBindingsWithContext:(id)context;

@end
