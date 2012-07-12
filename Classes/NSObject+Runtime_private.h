//
//  NSObject+Runtime_private.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//


@interface NSObject (CKRuntime_private)

+ (NSString*)concatenateAndUpperCaseFirstChar:(NSString*)input prefix:(NSString*)prefix suffix:(NSString*)suffix;

+ (SEL)selectorForProperty:(NSString*)property prefix:(NSString*)prefix suffix:(NSString*)suffix;
+ (SEL)selectorForProperty:(NSString*)property suffix:(NSString*)suffix;
+ (SEL)insertorForProperty : (NSString*)propertyName;
+ (SEL)keyValueInsertorForProperty : (NSString*)propertyName;
+ (SEL)typeCheckSelectorForProperty : (NSString*)propertyName;
+ (SEL)setSelectorForProperty : (NSString*)propertyName;
+ (SEL)propertyExtendedAttributesSelectorForProperty : (NSString*)propertyName;

+ (SEL)insertSelectorForProperty : (NSString*)propertyName;
+ (SEL)removeSelectorForProperty : (NSString*)propertyName;
+ (SEL)removeAllSelectorForProperty : (NSString*)propertyName;

- (void)introspection:(Class)c array:(NSMutableArray*)array;

@end
