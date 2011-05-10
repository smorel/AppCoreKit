//
//  CKTableViewCellNextResponder.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-10.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKTableViewCellController.h"


@interface CKTableViewCellNextResponder : NSObject {
}

+ (BOOL)needsNextKeyboard:(CKTableViewCellController*)controller;
+ (BOOL)setNextResponder:(CKTableViewCellController*)controller;

@end
