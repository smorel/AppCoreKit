//
//  CALayer+Introspection.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2013-11-08.
//  Copyright (c) 2013 Wherecloud. All rights reserved.
//

#import "CALayer+Introspection.h"
#import "NSValueTransformer+Additions.h"
#import "CKPropertyExtendedAttributes+Attributes.h"

#import "UIColor+ValueTransformer.h"
#import "UIImage+ValueTransformer.h"
#import "NSNumber+ValueTransformer.h"
#import "NSURL+ValueTransformer.h"
#import "NSDate+ValueTransformer.h"
#import "NSArray+ValueTransformer.h"
#import "CKCollection+ValueTransformer.h"
#import "NSIndexPath+ValueTransformer.h"
#import "NSObject+ValueTransformer.h"
#import "NSValueTransformer+NativeTypes.h"
#import "NSValueTransformer+CGTypes.h"
#import "CKConfiguration.h"

#import "CKDebug.h"

@implementation CALayer (Introspection)

- (void)insertSublayersObjects:(NSArray *)layers atIndexes:(NSIndexSet*)indexes{
    NSInteger i = 0;
	NSUInteger currentIndex = [indexes firstIndex];
	while (currentIndex != NSNotFound) {
		CALayer* layer = [layers objectAtIndex:i];
		[self insertSublayer:layer atIndex:(unsigned)currentIndex];
		currentIndex = [indexes indexGreaterThanIndex: currentIndex];
		++i;
	}
}

- (void)removeSublayersObjectsAtIndexes:(NSIndexSet*)indexes{
    NSArray* layers = [self.sublayers objectsAtIndexes:indexes];
	for(CALayer* layer in layers){
		[layer removeFromSuperlayer];
	}
}

- (void)removeAllSublayersObjects{
    NSArray* layers = [NSArray arrayWithArray:self.sublayers];
	for(CALayer* layer in layers){
		[layer removeFromSuperlayer];
	}
}

- (void)setSublayers:(NSArray *)sublayers{
    [self removeAllSublayersObjects];
    for(id object in sublayers){
        CALayer* layer = nil;
        if([object isKindOfClass:[CALayer class]]){
            layer = (CALayer*)object;
        }else if([object isKindOfClass:[NSDictionary class]]){
            layer = [NSValueTransformer objectFromDictionary:object];
        }else{
            CKAssert(NO,@"Non supported format");
        }
        [self addSublayer:layer];
    }
}

@end
