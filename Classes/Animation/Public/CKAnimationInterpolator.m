//
//  CKAnimationInterpolator.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 12-03-28.
//  Copyright (c) 2012 WhereCloud Inc. All rights reserved.
//

#import "CKAnimationInterpolator.h"
#import "CoreGraphics+Additions.h"

typedef enum CKAnimationInterpolatorType{
    CKAnimationInterpolatorTypeInvalid,
    CKAnimationInterpolatorTypeNumber,
    CKAnimationInterpolatorTypeCGAffineTransform,
    CKAnimationInterpolatorTypeCGPoint,
    CKAnimationInterpolatorTypeCGRect,
    CKAnimationInterpolatorTypeCGSize
}CKAnimationInterpolatorType;

@interface CKAnimationInterpolator()
@property(nonatomic,assign) CKAnimationInterpolatorType interpolationType;
@end

@implementation CKAnimationInterpolator
@synthesize values = _values;
@synthesize interpolationType = _interpolationType;

- (void)dealloc{
    [_values release];
    [super dealloc];
}

- (void)setValues:(NSArray *)thevalues{
    [_values release];
    _values = [thevalues retain];
    
    NSAssert([_values count] >= 2,@"Values must have 2 or more elements");
    Class c = [[_values objectAtIndex:0]class];
    for(id v in _values){
        if([v class] != c){
            NSAssert(NO,@"All items in values must be of the same class");
        }
    }
    
    self.interpolationType = CKAnimationInterpolatorTypeInvalid;
    
    id firstObject = [_values objectAtIndex:0];
    if([firstObject isKindOfClass:[NSNumber class]]){
        self.interpolationType = CKAnimationInterpolatorTypeNumber;
    }else if([firstObject isKindOfClass:[NSValue class]]){
        const char* type1 = [firstObject objCType];
        if(strcmp(type1,@encode(CGAffineTransform)) == 0)
            self.interpolationType = CKAnimationInterpolatorTypeCGAffineTransform;
        else if(strcmp(type1,@encode(CGPoint)) == 0)
            self.interpolationType = CKAnimationInterpolatorTypeCGPoint;
        else if(strcmp(type1,@encode(CGSize)) == 0)
            self.interpolationType = CKAnimationInterpolatorTypeCGSize;
        else if(strcmp(type1,@encode(CGRect)) == 0)
            self.interpolationType = CKAnimationInterpolatorTypeCGRect;
    }
    
    NSAssert(self.interpolationType != CKAnimationInterpolatorTypeInvalid,@"The values type is not supported by CKAnimationInterpolator");
}

- (id)interpolateFrom:(id)from to:(id)to withRatio:(CGFloat)ratio{
    if(_interpolationType == CKAnimationInterpolatorTypeNumber){
        CGFloat f1 = [from floatValue];
        CGFloat f2 = [to floatValue];
        return [NSNumber numberWithFloat:(f1 + ((f2 - f1) * ratio))];
    }
    else if(_interpolationType == CKAnimationInterpolatorTypeCGAffineTransform){
        CGAffineTransform value =  CKCGAffineTransformInterpolate([from CGAffineTransformValue],[to CGAffineTransformValue],ratio);
        return [NSValue valueWithCGAffineTransform:value];
    }
    else if(_interpolationType == CKAnimationInterpolatorTypeCGPoint){
        CGPoint p1 = [from CGPointValue];
        CGPoint p2 = [to CGPointValue];
        CGFloat x = p1.x + ((p2.x - p1.x) * ratio);
        CGFloat y = p1.y + ((p2.y - p1.y) * ratio);
        return [NSValue valueWithCGPoint:CGPointMake(x, y)];
    }
    else if(_interpolationType == CKAnimationInterpolatorTypeCGSize){
        CGSize s1 = [from CGSizeValue];
        CGSize s2 = [to CGSizeValue];
        CGFloat width = s1.width + ((s2.width - s1.width) * ratio);
        CGFloat height = s1.height + ((s2.height - s1.height) * ratio);
        return [NSValue valueWithCGSize:CGSizeMake(width, height)];
        
    }
    else if(_interpolationType == CKAnimationInterpolatorTypeCGRect){
        CGRect r1 = [from CGRectValue];
        CGRect r2 = [to CGRectValue];
        CGFloat x = r1.origin.x + ((r2.origin.x - r1.origin.x) * ratio);
        CGFloat y = r1.origin.y + ((r2.origin.y - r1.origin.y) * ratio); 
        CGFloat width = r1.size.width + ((r2.size.width - r1.size.width) * ratio);
        CGFloat height = r1.size.height + ((r2.size.height - r1.size.height) * ratio);
        return [NSValue valueWithCGRect:CGRectMake(x,y,width, height)];
    }
    NSAssert(NO,@"Interpolation not supported for this type");
    return nil;
}

- (void)updateUsingRatio:(CGFloat)ratio{
    if([_values count] < 2 || _interpolationType == CKAnimationInterpolatorTypeInvalid){
        NSAssert(NO,@"Interpolator has not been initialized correctly");
        return;
    }
    
    NSInteger f = (NSInteger)(floor(ratio * (CGFloat)([_values count]-1)));
    if(f >= [_values count]-1){
        if(self.updateBlock){
            self.updateBlock(self,[_values objectAtIndex:f]);
        }
    }else{
        CGFloat ratioFloor = f / (float)([_values count]-1);
        CGFloat ratioDiff = ratio - ratioFloor;
        CGFloat inBetweenRatio = ratioDiff * (float)([_values count]-1);
        
        id fromValue = [_values objectAtIndex:f];
        id toValue = [_values objectAtIndex:f+1];
        id value = [self interpolateFrom:fromValue to:toValue withRatio:inBetweenRatio];
        if(self.updateBlock){
            self.updateBlock(self,value);
        }
    }
}

@end


@implementation CKAnimationPropertyInterpolator
@dynamic updateBlock;

+ (CKAnimationPropertyInterpolator*)animationWithObject:(id)object keyPath:(NSString*)keyPath{
    return [[[CKAnimationPropertyInterpolator alloc]initWithObject:object keyPath:keyPath]autorelease];
}

- (id)initWithObject:(id)object keyPath:(NSString*)keyPath{
    self = [super init];
    
    __block id bobject = object;
    self.updateBlock = ^(CKAnimation* animation, id value){
        [bobject setValue:value forKeyPath:keyPath];
    };
    return self;
}


@end

