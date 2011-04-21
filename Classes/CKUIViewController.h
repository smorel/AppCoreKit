//
//  CKUIViewController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-04-21.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CKUIViewController : UIViewController {
	NSString* _name;
}

@property (nonatomic,retain) NSString* name;

@end
