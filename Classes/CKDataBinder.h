//
//  CKDataBinder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-02-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


@interface CKDataBinder : NSObject {
	id instance1;
	NSString* keyPath1;
	id instance2;
	NSString* keyPath2;
}

@property (nonatomic, retain) id instance1;
@property (nonatomic, retain) NSString *keyPath1;
@property (nonatomic, retain) id instance2;
@property (nonatomic, retain) NSString *keyPath2;

+(CKDataBinder*)binderForObject:(id)object1 keyPath:(NSString*)keyPath object2:(id)object2 keyPath2:(NSString*)keyPath2;

-(void)bind;


@end
