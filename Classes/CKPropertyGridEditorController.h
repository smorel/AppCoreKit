//
//  RXPropertyGridEditorController.h
//  Prescripteur
//
//  Created by Sebastien Morel on 11-05-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKFormTableViewController.h"
#import "CKObjectProperty.h"


/** TODO
    CKPropertyGridEditorController is DEPRECATED_IN_CLOUDKIT_VERSION_1_7_AND_LATER
 */
@interface CKPropertyGridEditorController : CKFormTableViewController{
	UIPopoverController* editorPopover;
	id _object;
}

@property (nonatomic, retain) UIPopoverController *editorPopover;

- (id)initWithObjectProperties:(NSArray*)properties DEPRECATED_ATTRIBUTE;
- (id)initWithObject:(id)object DEPRECATED_ATTRIBUTE;

- (void)setupWithObject:(id)object DEPRECATED_ATTRIBUTE;
- (void)setupWithObject:(id)object withFilter:(NSString*)filter DEPRECATED_ATTRIBUTE;
- (void)setupWithProperties:(NSArray*)properties DEPRECATED_ATTRIBUTE;

@end
