//
//  RXPropertyGridEditorController.h
//  Prescripteur
//
//  Created by Sebastien Morel on 11-05-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <CloudKit/CKFormTableViewController.h>
#import <CloudKit/CKObjectProperty.h>


@interface CKPropertyGridEditorController : CKFormTableViewController{
	UIPopoverController* editorPopover;
}

@property (nonatomic, retain) UIPopoverController *editorPopover;

- (id)initWithObjectProperties:(NSArray*)properties;
- (id)initWithObject:(id)object representation:(NSDictionary*)representation;
- (id)initWithObject:(id)object;
- (void)setup:(NSArray*)properties;

@end