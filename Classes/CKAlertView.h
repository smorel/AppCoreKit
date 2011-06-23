//
//  CKAlertView.h
//  CloudKit
//
//  Created by Fred Brunel on 10-09-06.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CKAlertView : UIAlertView {
	id _object;
}

@property (nonatomic, retain) id object;

@end
