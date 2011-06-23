//
//  CKTableViewCellNextResponder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKTableViewCellController.h"


@interface CKTableViewCellNextResponder : NSObject {
}

+ (BOOL)needsNextKeyboard:(CKTableViewCellController*)controller;
+ (BOOL)activateNextResponderFromController:(CKTableViewCellController*)controller;

@end
