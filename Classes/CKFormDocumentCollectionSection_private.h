//
//  CKFormDocumentCollectionSection_private.h
//  CloudKit
//
//  Created by Sebastien Morel.
//  Copyright (c) 2011 Wherecloud. All rights reserved.
//

@interface CKFormDocumentCollectionSection()
@property (nonatomic,retain) CKDocumentCollectionController* objectController;
@property (nonatomic,retain) CKItemViewControllerFactory* controllerFactory;
@property (nonatomic,retain) NSMutableArray* changeSet;

@property (nonatomic,retain,readwrite) NSMutableArray* headerCellDescriptors;
@property (nonatomic,retain,readwrite) NSMutableArray* footerCellDescriptors;
@end