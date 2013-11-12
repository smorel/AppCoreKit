//
//  CALayer+Introspection.h
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-08.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CALayer (Introspection)

- (void)insertSublayersObjects:(NSArray *)layers atIndexes:(NSIndexSet*)indexes;
- (void)removeSublayersObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)removeAllSublayersObjects;

@end
