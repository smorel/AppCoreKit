//
//  CKBasicCellController.h
//  CloudKit
//
//  Created by Oli Kenobi on 09-12-15.
//  Copyright 2009 Kenobi Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IFCellController.h"
#import "IFCellModel.h"

@interface CKBasicCellController : NSObject <IFCellController> {
	id _target;
	SEL _action;
	
	BOOL isSelectable;
}

@property (nonatomic, assign) BOOL isSelectable;

- (void)setAction:(SEL)action onTarget:(id)target;

@end
