//
//  CKOptionPropertyCellController.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKPropertyGridCellController.h"
#import "CKOptionTableViewController.h"


@interface CKOptionPropertyCellController : CKPropertyGridCellController  <CKOptionTableViewControllerDelegate>{
}

@property (nonatomic,assign) CKTableViewCellStyle optionCellStyle;
@property (nonatomic,retain,readonly) CKOptionTableViewController* optionsViewController;



@end
