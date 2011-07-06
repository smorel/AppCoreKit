//
//  CKRigoloDefaultBehaviour.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-06.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKRigoloDefaultBehaviour.h"
#import "CKLocalization.h"
#import "CKAlertView.h"
#import "CKFormTableViewController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSDictionary+TableViewAttributes.h"

//CKRigoloDefaultBehaviourBarButtonItem

@interface CKRigoloDefaultBehaviourBarButtonItem : UIBarButtonItem{
    id _userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKRigoloDefaultBehaviourBarButtonItem
@synthesize userInfo = _userInfo;
@end


//CKRigoloDefaultBehaviour

@interface CKRigoloDefaultBehaviour()
- (void)displayRigoItemDetails:(CKRigoloItem*)item parentController:(UIViewController*)parentController;
- (void)displayRigoItemList:(NSArray*)items;
- (void)dismissModal:(id)sender;
- (void)install:(id)sender;
@property(nonatomic,retain) NSArray* items;
@end

@implementation CKRigoloDefaultBehaviour
@synthesize items = _items;

- (void)dealloc{
    [_items release];
    _items = nil;
    [super dealloc];
}

- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService isUpToDateWithVersion:(NSString*)version{
    //DO NOTHING
}

- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService needsUpdateToVersion:(NSString*)version{
    NSString* title = _(@"New Version Available");
    NSString* message = [NSString stringWithFormat:_(@"Build (%@)"),version];
    CKAlertView* alertView = [[[CKAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:_(@"Cancel") otherButtonTitles:(@"Details"),nil]autorelease];
    alertView.object = [NSDictionary dictionaryWithObjectsAndKeys:rigoloWebService,@"webService",version,@"version", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    CKAlertView* ckAlertView = (CKAlertView*)alertView;
    switch(buttonIndex){
        case 1:{
            CKRigoloWebService* webService = [ckAlertView.object objectForKey:@"webService"];
            NSString* version = [ckAlertView.object objectForKey:@"version"];
            [webService detailsForVersion:version];
            break;
        }
    }
}

- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService didReceiveDetails:(CKRigoloItem*)details{
    [self displayRigoItemDetails:details parentController:nil];
}

- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService didReceiveItemList:(NSArray*)rigoloItems{
    [self displayRigoItemList:rigoloItems];
}

- (void)displayRigoItemDetails:(CKRigoloItem*)item parentController:(UIViewController*)parentController{
    CKFormTableViewController* formController = [[[CKFormTableViewController alloc]init]autorelease];
    formController.title = [NSString stringWithFormat:_(@"Version %@"),item.buildVersion];
   
    CKFormCellDescriptor* bundleIdentifierCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:item controllerClass:[CKTableViewCellController class]];
    [bundleIdentifierCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloBundleIdCell";
        controller.cellStyle = CKTableViewCellStyleValue3;
        return (id)nil; 
    }];
    [bundleIdentifierCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKRigoloItem* item = (CKRigoloItem*)controller.value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.tableViewCell.textLabel.text = _(@"Bundle Identifier");
        controller.tableViewCell.detailTextLabel.text = item.bundleIdentifier;
        return (id)nil; 
        
    }];
    CKFormCellDescriptor* appNameCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:item controllerClass:[CKTableViewCellController class]];
    [appNameCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloAppNameCell";
        controller.cellStyle = CKTableViewCellStyleValue3;
        return (id)nil; 
    }];
    [appNameCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKRigoloItem* item = (CKRigoloItem*)controller.value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.tableViewCell.textLabel.text = _(@"Application Name");
        controller.tableViewCell.detailTextLabel.text = item.applicationName;
        return (id)nil; 
        
    }];
    CKFormCellDescriptor* releaseDateCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:item controllerClass:[CKTableViewCellController class]];
    [releaseDateCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseDateCell";
        controller.cellStyle = CKTableViewCellStyleValue3;
        return (id)nil; 
    }];
    [releaseDateCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKRigoloItem* item = (CKRigoloItem*)controller.value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.tableViewCell.textLabel.text = _(@"Release Date");
        controller.tableViewCell.detailTextLabel.text = [NSValueTransformer transform:item.releaseDate toClass:[NSString class]];
        return (id)nil; 
        
    }];
    CKFormCellDescriptor* releaseNotesCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:item controllerClass:[CKTableViewCellController class]];
    [releaseNotesCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseNotesCell";
        controller.cellStyle = CKTableViewCellStyleDefault;
        return (id)nil; 
    }];
    [releaseNotesCellDescriptor setInitBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel* label = [[[UILabel alloc]initWithFrame:CGRectInset(controller.tableViewCell.contentView.bounds,10,10)]autorelease];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.numberOfLines = 0;
        label.tag = 10000;
        [controller.tableViewCell.contentView addSubview:label];
        return (id)nil; 
    }];
    [releaseNotesCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKRigoloItem* item = (CKRigoloItem*)controller.value;
        UILabel* label = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10000];
        label.text = item.releaseNotes;
        return (id)nil; 
    }];
    [releaseNotesCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CKRigoloItem* item = (CKRigoloItem*)[params object];
        CGSize tableViewSize = [params bounds];
    
        CGSize  size = (item.releaseNotes != nil && ![item.releaseNotes isEqualToString:@""]) ? 
            [item.releaseNotes sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(tableViewSize.width - 20, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap]
            : CGSizeMake(0,0);
        
        return [NSValue valueWithCGSize:CGSizeMake(size.width,size.height + 20)]; 
    }];
    [formController addSectionWithCellDescriptors:[NSArray arrayWithObjects:bundleIdentifierCellDescriptor,appNameCellDescriptor,releaseDateCellDescriptor,releaseNotesCellDescriptor,nil]];
     
    //Setup navigation and push controller
    CKRigoloDefaultBehaviourBarButtonItem* installButton = [[[CKRigoloDefaultBehaviourBarButtonItem alloc]initWithTitle:_(@"Install") 
                                                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                                                 target:self 
                                                                                                                 action:@selector(install:)] autorelease];
    installButton.userInfo = item;
    
    formController.rightButton = installButton;
    if(parentController == nil){
        UIViewController* rootController = [[[UIApplication sharedApplication]keyWindow]rootViewController];
        if(rootController.modalViewController == nil){
            UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:formController]autorelease];
            formController.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                      target:self 
                                                                                      action:@selector(dismissModal:)] autorelease];
            [rootController presentModalViewController:navController animated:YES];
        }
    }
    else{
        [parentController.navigationController pushViewController:formController animated:YES];
    }
}

- (void)displayRigoItemList:(NSArray*)theItems{
    UIViewController* rootController = [[[UIApplication sharedApplication]keyWindow]rootViewController];
    if(rootController.modalViewController == nil){
        self.items = theItems;
        
        NSMutableArray* mappings = [NSMutableArray array];
        CKObjectViewControllerFactoryItem* rigoloCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[CKRigoloItem class]];
        [rigoloCellDescriptor setCreateBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            controller.name = @"rigoloCell";
            controller.cellStyle = CKTableViewCellStyleSubtitle;
            return (id)nil; 
        }];
        [rigoloCellDescriptor setInitBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            controller.tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return (id)nil; 
        }];
        [rigoloCellDescriptor setSetupBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            CKRigoloItem* item = (CKRigoloItem*)controller.value;
            controller.tableViewCell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",item.applicationName,item.buildVersion];
            controller.tableViewCell.detailTextLabel.text = [NSValueTransformer transform:item.releaseDate toClass:[NSString class]];
            return (id)nil; 
            
        }];
        [rigoloCellDescriptor setSelectionBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            CKRigoloItem* item = (CKRigoloItem*)controller.value;
            [self displayRigoItemDetails:item parentController:controller.parentController];
            return (id)nil;
        }];
        [rigoloCellDescriptor setFlags:CKItemViewFlagSelectable];
        
        CKObjectPropertyArrayCollection* collection = [CKObjectPropertyArrayCollection collectionWithArrayProperty:[CKObjectProperty propertyWithObject:self keyPath:@"items"]];
        CKObjectTableViewController* tableViewController = [[[CKObjectTableViewController alloc]initWithCollection:collection mappings:mappings]autorelease];
        tableViewController.title = _(@"Versions");
        
        
        UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:tableViewController]autorelease];
        tableViewController.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal:)] autorelease];
        [rootController presentModalViewController:navController animated:YES];
    }
}

- (void)install:(id)sender{
    CKRigoloDefaultBehaviourBarButtonItem* installButton = (CKRigoloDefaultBehaviourBarButtonItem*)sender;
    CKRigoloItem* item = installButton.userInfo;
    [[CKRigoloWebService sharedWebService]install:item];
}

- (void)dismissModal:(id)sender{
    UIViewController* rootController = [[[UIApplication sharedApplication]keyWindow]rootViewController];
    [rootController dismissModalViewControllerAnimated:YES];
}

//DEBUG IMPLEMENTATION WHILE API IS NOT READY

- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService checkFailedWithError:(NSError*)error{
    NSMutableArray* items = [NSMutableArray array];
    for(int i =0;i<10;++i){
        CKRigoloItem* item = [CKRigoloItem model];
        item.applicationName = @"TOTO";
        item.bundleIdentifier = @"com.wherecloud.TOTO";
        item.releaseDate = [NSDate date];
        item.buildVersion = [NSString stringWithFormat:@"%d",i];
        item.releaseNotes = [NSString stringWithFormat:@"THE RELEASE NOTES\r\nFOR VERSION %d\r\nOF THE APPLICATION TOTO",i];
        [items addObject:item];
    }
    [self displayRigoItemList:items];
}

- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService listFailedWithError:(NSError*)error{
    
}

- (void)rigoloWebService:(CKRigoloWebService*)rigoloWebService detailsForVersion:(NSString*)version failedWithError:(NSError*)error{
    
}

@end
