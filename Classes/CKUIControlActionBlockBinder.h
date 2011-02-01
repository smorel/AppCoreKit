//
//  CKViewExecutionBlock.h
//  NFB
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

typedef void(^CKUIControlActionBlock)();


@interface CKUIControlActionBlockBinder : NSObject{
	NSNumber* viewTag;
	UIControlEvents controlEvents;
	CKUIControlActionBlock actionBlock;
	
	UIControl* control;
}

@property (nonatomic, retain) NSNumber *viewTag;
@property (nonatomic, assign) UIControlEvents controllEvents;
@property (nonatomic, retain) CKUIControlActionBlock actionBlock;

-(void)bindControlInView:(UIView*)controlView;

@end
