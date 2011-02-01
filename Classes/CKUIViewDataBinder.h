//
//  CKViewDataBinder.h
//  CloudKitApp
//
//  Created by Sebastien Morel on 11-01-26.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

@interface CKUIViewDataBinder : NSObject{
	NSNumber* viewTag;
	NSString* keyPath;
	UIControlEvents controlEvents;
	
	id target;
	NSString* targetKeyPath;
	
	//Internal
	UIView* view;
}

@property (nonatomic, retain) NSNumber *viewTag;
@property (nonatomic, retain) NSString *keyPath;
@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSString *targetKeyPath;
@property (nonatomic, assign) UIControlEvents controllEvents;

-(void)bindViewInView:(UIView*)theView;

@end
