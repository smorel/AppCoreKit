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


@interface CKPropertyGridEditorController : CKFormTableViewController{
	UIPopoverController* editorPopover;
	id _object;
}

@property (nonatomic, retain) UIPopoverController *editorPopover;

- (id)initWithObjectProperties:(NSArray*)properties;
- (id)initWithObject:(id)object representation:(NSDictionary*)representation;
- (id)initWithObject:(id)object;


- (void)setupWithObject:(id)object;
- (void)setupWithObject:(id)object withFilter:(NSString*)filter;
- (void)setupWithObject:(id)object representation:(NSDictionary*)representation;
- (void)setupWithProperties:(NSArray*)properties;

@end