//
//  CKPropertyGridCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-08.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKTableViewCellController.h"
#import "CKObjectProperty.h"


@interface CKPropertyGridCellController : CKTableViewCellController {
}

@property(nonatomic,assign)BOOL readOnly;

- (CKObjectProperty*)objectProperty;

@end
