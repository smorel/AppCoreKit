//
//  NSTimer+BlockBaseInterface.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2012 Wherecloud. All rights reserved.
//

#import "NSTimer+BlockBaseInterface.h"
#import <objc/runtime.h>

typedef void (^NSTimerBlock) (NSTimer* timer);

@interface NSTimerBlockPerformer : NSObject
@property (nonatomic,copy) NSTimerBlock block;

- (void)execute:(NSTimer*)theTimer;

@end

@implementation NSTimerBlockPerformer
@synthesize block = _block;

- (void)dealloc{
    [_block release];
    _block = nil;
    [super dealloc];
}

- (void)execute:(NSTimer*)theTimer{
    if(_block){
        _block(theTimer);
    }
}

@end



@interface NSTimer(CKBlockBaseInterfaceProvate)
@property(nonatomic,retain) NSTimerBlockPerformer* blockPerformer;
@end

static char NSTimerBlockPerformerKey;

@implementation NSTimer(CKBlockBaseInterfaceProvate)
@dynamic blockPerformer;

- (NSTimerBlockPerformer*)blockPerformer{
    return objc_getAssociatedObject(self, &NSTimerBlockPerformerKey);
}

- (void)setBlockPerformer:(NSTimerBlockPerformer*)blockPerformer{
    objc_setAssociatedObject(self, 
                             &NSTimerBlockPerformerKey,
                             blockPerformer,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSTimer (CKBlockBaseInterface)

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer* timer))block{
    NSTimerBlockPerformer* blockPerformer = [[[NSTimerBlockPerformer alloc]init]autorelease];
    blockPerformer.block = block;
    NSTimer* timer = [NSTimer timerWithTimeInterval:ti target:blockPerformer selector:@selector(execute:) userInfo:nil repeats:yesOrNo];
    timer.blockPerformer = blockPerformer;
    return timer;
}
 
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer* timer))block{
    NSTimerBlockPerformer* blockPerformer = [[[NSTimerBlockPerformer alloc]init]autorelease];
    blockPerformer.block = block;
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:ti target:blockPerformer selector:@selector(execute:) userInfo:nil repeats:yesOrNo];
    timer.blockPerformer = blockPerformer;
    return timer;
}

@end
