//
//  CKOptionPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-08-15.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKOptionTableViewController.h"


@interface CKOptionPropertyCellController : CKPropertyGridCellController  <CKOptionTableViewControllerDelegate>{
}

@property (nonatomic,assign) CKTableViewCellStyle optionCellStyle;

@end
