//
//  CKNSDatePropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKPropertyGridCellController.h"
#include "CKSheetController.h"


/** TODO
 */
@interface CKNSDatePropertyCellController : CKPropertyGridCellController<CKSheetControllerDelegate,UIPopoverControllerDelegate> {
    BOOL _registeredOnOrientationChange;
}

@end
