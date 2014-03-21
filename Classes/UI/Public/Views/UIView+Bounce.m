//
//  UIView+Bounce.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 3/19/2014.
//  Copyright (c) 2014 Wherecloud. All rights reserved.
//

#import "UIView+Bounce.h"
#import "CKAnimationInterpolator.h"
#import "CKAnimationManager.h"

static CKAnimationManager* sharedAnimationManagerForBounces = nil;
static NSInteger sharedAnimationManagerRefCount = 0;

@implementation UIView (Bounce)

- (void)animateWithBounceFromFrame:(CGRect)startFrame
                           toFrame:(CGRect)endFrame
                          duration:(NSTimeInterval)duration
                            update:(void(^)(CGRect frame))update
                        completion:(void(^)(BOOL finished))completion{
    [self animateWithBounceFromFrame:startFrame toFrame:endFrame duration:duration numberOfBounce:10 numberOfSteps:(duration * 60) damping:9 update:update completion:completion];
}


- (void)animateWithBounceFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame duration:(NSTimeInterval)duration
                    numberOfBounce:(NSInteger)numberOfBounces damping:(CGFloat)damping
                            update:(void(^)(CGRect frame))update
                        completion:(void(^)(BOOL finished))completion{
    [self animateWithBounceFromFrame:startFrame toFrame:endFrame duration:duration numberOfBounce:numberOfBounces numberOfSteps:(duration * 60) damping:damping update:update completion:completion];
}

- (void)animateWithBounceFromFrame:(CGRect)startFrame toFrame:(CGRect)endFrame duration:(NSTimeInterval)duration
                    numberOfBounce:(NSInteger)numberOfBounces numberOfSteps:(NSInteger)steps damping:(CGFloat)damping
                            update:(void(^)(CGRect frame))update
                        completion:(void(^)(BOOL finished))completion{
    
    
    CKAnimationInterpolator* interpolator = [[[CKAnimationInterpolator alloc]init]autorelease];
    interpolator.values = [UIView bouncesValuesWithStartFrame:startFrame endFrame:endFrame numberOfBounce:numberOfBounces numberOfSteps:steps damping:damping];
    interpolator.duration = duration;
    interpolator.updateBlock = ^(CKAnimation* animation,id value){
        self.frame = [value CGRectValue];
        if(update){
            update(self.frame);
        }
    };
    
    interpolator.eventBlock = ^(CKAnimation* animation,CKAnimationEvents event){
        if(event == CKAnimationEventEnd){
            if(completion){
                completion(YES);
            }
            --sharedAnimationManagerRefCount;
            if(sharedAnimationManagerRefCount == 0){
                [sharedAnimationManagerForBounces unregisterFromScreen];
                [sharedAnimationManagerForBounces release];
                sharedAnimationManagerForBounces = nil;
            }
        }
    };
    
    if(!sharedAnimationManagerForBounces){
        sharedAnimationManagerForBounces = [[CKAnimationManager alloc]init];
        [sharedAnimationManagerForBounces registerInScreen:self.window.screen];
    }
    ++sharedAnimationManagerRefCount;
    
    [interpolator startInManager:sharedAnimationManagerForBounces];
}

+ (NSArray*)bouncesValuesWithStartFrame:(CGRect)startValue endFrame:(CGRect)endValue numberOfBounce:(NSInteger)numberOfBounces numberOfSteps:(NSInteger)steps damping:(CGFloat)damping{
    CGFloat alpha = 0;
	if (CGRectEqualToRect(startValue, endValue)) {
		alpha = log2f(0.1f)/steps;
	} else {
        CGPoint delta = CGPointMake( endValue.origin.x - startValue.origin.x, endValue.origin.y - startValue.origin.y);
        CGFloat distance = sqrtf((delta.x * delta.x) + (delta.y * delta.y));
        
		alpha = log2f(0.1f/distance)/steps;
	}
	if (alpha > 0) {
		alpha = -1.0f*alpha;
	}
    
    CGFloat numberOfPeriods = numberOfBounces/2;
	CGFloat omega = numberOfPeriods * 2 * M_PI/steps;
    
	//uncomment this to get the equation of motion
	//	NSLog(@"y = %0.2f * e^(%0.5f*x)*cos(%0.10f*x) + %0.0f over %d frames", startValue - endValue, alpha, omega, endValue, steps);
    
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
	CGFloat valueX = 0,valueY = 0;
    
	CGFloat sign = 1;
    
	CGFloat oscillationComponent;
	CGFloat coefficientX,coefficientY;
    
    BOOL shake = NO;
    BOOL shouldOvershoot = YES;
    
	// conforms to y = A * e^(-alpha*t)*cos(omega*t)
	for (int t = 0; t < steps; t++) {
		//decaying mass-spring-damper solution with initial displacement
        
		if (shake) {
			oscillationComponent =  sin(omega*t);
		} else {
			oscillationComponent =  cos(omega*t);
		}
        
		if (shouldOvershoot) {
			coefficientX =  (startValue.origin.x - endValue.origin.x);
			coefficientY =  (startValue.origin.y - endValue.origin.y);
		} else {
			coefficientX = -1 * sign * fabsf((startValue.origin.x - endValue.origin.x));
			coefficientY = -1 * sign * fabsf((startValue.origin.y - endValue.origin.y));
		}
        
		valueX = coefficientX * pow(damping, alpha*t) * oscillationComponent + endValue.origin.x;
		valueY = coefficientY * pow(damping, alpha*t) * oscillationComponent + endValue.origin.y;
        
        CGRect rect = CGRectMake(valueX, valueY, startValue.size.width, startValue.size.height);
        [values addObject:[NSValue valueWithCGRect:rect]];
	}
    
    return values;
}


@end
