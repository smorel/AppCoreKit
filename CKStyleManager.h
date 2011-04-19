//
//  CKStyleManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-19.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CKStyleManager : NSObject {
	NSMutableDictionary* _styles;
}

+ (void)setStyle:(id)style forKey:(NSString*)key;
+ (id)styleForKey:(NSString*)key;

//Could extend to load style from files ...

@end
