//
//  CKFormBindedCollectionSection_private.h
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

#import "CKFormBindedCollectionSection.h"

@interface CKFormBindedCollectionSection(){
	BOOL _sectionUpdate;
}

@property (nonatomic,retain) CKCollectionController* objectController;
@property (nonatomic,retain) CKCollectionCellControllerFactory* controllerFactory;

@property (nonatomic,retain,readwrite) NSMutableArray* headerCellControllers;
@property (nonatomic,retain,readwrite) NSMutableArray* footerCellControllers;
@end