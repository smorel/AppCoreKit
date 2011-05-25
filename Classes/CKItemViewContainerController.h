//
//  CKItemViewContainerController.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-25.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKUIViewController.h"

/* This controller implements the logic to deals with objects via objectcontroller and controllerfactory.
   It will gives all the basic logic for live update from documents/view creation and reusing, controller creation/reusing
   and manage the item controller flags/selection/remove, ...
 
   By derivating this controller, you'll just have to implement the UIKit specific delegates and view creation and redirect
   to the basic implementation of CKItemViewContainerController
 
   By this way we centralize all the document/viewcontroller logic taht is redondant in this class
 
   For some specific implementations see : CKObjectTableViewController, CKObjectCarouselViewController and CKMapViewController
*/

@interface CKItemViewContainerController : CKUIViewController {
}

@end
