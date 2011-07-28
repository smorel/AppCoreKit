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
 */
@interface CKPropertyGridEditorController : CKFormTableViewController{
	UIPopoverController* editorPopover;
	id _object;
}

@property (nonatomic, retain) UIPopoverController *editorPopover;

- (id)initWithObjectProperties:(NSArray*)properties;
- (id)initWithObject:(id)object representation:(NSArray*)representation;
- (id)initWithObject:(id)object;


- (void)setupWithObject:(id)object;
- (void)setupWithObject:(id)object withFilter:(NSString*)filter;
- (void)setupWithObject:(id)object representation:(NSArray*)representation;
- (void)setupWithProperties:(NSArray*)properties;

@end

@interface NSMutableArray (CKPropertyGridEditorController)
- (void)addSectionWithHeaderTitle:(NSString*)title withProperties:(NSArray*)properties;
- (void)addSectionWithHeaderTitle:(NSString*)title withProperties:(NSArray*)properties withBlock:(void(^)(CKPropertyGridEditorController* controller))block;
- (void)addSectionWithHeaderTitle:(NSString*)title withProperties:(NSArray*)properties hidden:(BOOL)hidden;
- (void)addSectionWithHeaderTitle:(NSString*)title withProperties:(NSArray*)properties withBlock:(void(^)(CKPropertyGridEditorController* controller))block hidden:(BOOL)hidden;
@end