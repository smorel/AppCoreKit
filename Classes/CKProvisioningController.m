//
//  CKProvisioningController.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-07-06.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKProvisioningController.h"
#import "CKLocalization.h"
#import "CKAlertView.h"
#import "CKFormTableViewController.h"
#import "CKObjectPropertyArrayCollection.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSDictionary+TableViewAttributes.h"
#import "CKProvisioningWebService.h"

//CKRigoloDefaultBehaviourBarButtonItem

@interface CKProvisioningControllerBarButtonItem : UIBarButtonItem{
    id _userInfo;
}
@property(nonatomic,retain)id userInfo;
@end

@implementation CKProvisioningControllerBarButtonItem
@synthesize userInfo = _userInfo;
@end


//CKRigoloDefaultBehaviour

@interface CKProvisioningController()
- (void)checkForNewProductRelease;
- (void)listAllProductReleases;
- (void)detailsForProductRelease:(NSString*)version;
- (void)displayProductRelease:(CKProductRelease*)productRelease parentController:(UIViewController*)parentController;
- (void)displayProductReleases:(NSArray*)productReleases;
@property(nonatomic,retain) NSArray* items;
@end

@implementation CKProvisioningController
@synthesize items = _items;
@synthesize parentViewController = _parentViewController;

- (id)initWithParentViewController:(UIViewController*)controller{
    [super init];
    self.parentViewController = controller;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    return self;
}

- (void)dealloc{
    [_items release];
    _items = nil;
    [_parentViewController release];
    _parentViewController = nil;
    [super dealloc];
}

- (void)onBecomeActive:(NSNotification*)notif{
    [self checkForNewProductRelease];
}

- (void)checkForNewProductRelease{
    NSString* buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    
    [[CKProvisioningWebService sharedWebService]checkForNewProductReleaseWithBundleIdentifier:bundleIdentifier 
                                                                               version:buildVersion
     
                                                                               completion:^(BOOL upToDate,NSString* version){
                                                                                if(!upToDate){
                                                                                    NSString* title = _(@"New Version Available");
                                                                                    NSString* message = [NSString stringWithFormat:_(@"Build (%@)"),version];
                                                                                    CKAlertView* alertView = [[[CKAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:_(@"Cancel") otherButtonTitles:(@"Details"),nil]autorelease];
                                                                                    alertView.object = [NSDictionary dictionaryWithObjectsAndKeys:version,@"version", nil];
                                                                                    [alertView show];
                                                                                }
                                                                                else{
                                                                                    CKAlertView* alertView = [[[CKAlertView alloc]initWithTitle:@"UpToDate" message:@"" delegate:self cancelButtonTitle:_(@"Ok") otherButtonTitles:nil]autorelease];
                                                                                    [alertView show];
                                                                                }
                                                                               }
     
                                                                               failure:^(NSError* error){
                                                                                   NSMutableArray* items = [NSMutableArray array];
                                                                                   for(int i =0;i<10;++i){
                                                                                       CKProductRelease* item = [CKProductRelease model];
                                                                                       item.applicationName = @"TOTO";
                                                                                       item.bundleIdentifier = @"com.wherecloud.TOTO";
                                                                                       item.releaseDate = [NSDate date];
                                                                                       item.buildVersion = [NSString stringWithFormat:@"%d",i];
                                                                                       item.releaseNotes = [NSString stringWithFormat:@"THE RELEASE NOTES\r\nFOR VERSION %d\r\nOF THE APPLICATION TOTO",i];
                                                                                       [items addObject:item];
                                                                                   }
                                                                                   [self displayProductReleases:items];
                                                                               }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    CKAlertView* ckAlertView = (CKAlertView*)alertView;
    switch(buttonIndex){
        case 1:{
            NSString* version = [ckAlertView.object objectForKey:@"version"];
            [self detailsForProductRelease:version];
            break;
        }
    }
}

- (void)detailsForProductRelease:(NSString*)version{
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    [[CKProvisioningWebService sharedWebService]detailsForProductRelease:version 
                                                 bundleIdentifier:bundleIdentifier
                                                       completion:^(CKProductRelease* productRelease){
                                                           [self displayProductRelease:productRelease parentController:nil];
                                                       }
                                                          failure:^(NSError* error){
                                                          }];
}

- (void)listAllProductReleases{
    NSString* bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    [[CKProvisioningWebService sharedWebService]listAllProductReleasesWithBundleIdentifier:bundleIdentifier 
                                                                         completion:^(NSArray* productReleases){
                                                                             [self displayProductReleases:productReleases];
                                                                         }
                                                                            failure:^(NSError* error){
                                                                            }];
    
}


- (void)displayProductRelease:(CKProductRelease*)productRelease parentController:(UIViewController*)parentController{
    CKFormTableViewController* formController = [[[CKFormTableViewController alloc]init]autorelease];
    formController.title = [NSString stringWithFormat:_(@"Version %@"),productRelease.buildVersion];
   
    CKFormCellDescriptor* bundleIdentifierCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [bundleIdentifierCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloBundleIdCell";
        controller.cellStyle = CKTableViewCellStyleValue3;
        return (id)nil; 
    }];
    [bundleIdentifierCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.tableViewCell.textLabel.text = _(@"Bundle Identifier");
        controller.tableViewCell.detailTextLabel.text = productRelease.bundleIdentifier;
        return (id)nil; 
        
    }];
    CKFormCellDescriptor* appNameCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [appNameCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloAppNameCell";
        controller.cellStyle = CKTableViewCellStyleValue3;
        return (id)nil; 
    }];
    [appNameCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.tableViewCell.textLabel.text = _(@"Application Name");
        controller.tableViewCell.detailTextLabel.text = productRelease.applicationName;
        return (id)nil; 
        
    }];
    CKFormCellDescriptor* releaseDateCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
    [releaseDateCellDescriptor setCreateBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        controller.name = @"rigoloReleaseDateCell";
        controller.cellStyle = CKTableViewCellStyleValue3;
        return (id)nil; 
    }];
    [releaseDateCellDescriptor setSetupBlock:^id(id value) {
        CKTableViewCellController* controller = (CKTableViewCellController*)value;
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
        controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        controller.tableViewCell.textLabel.text = _(@"Release Date");
        controller.tableViewCell.detailTextLabel.text = [NSValueTransformer transform:productRelease.releaseDate toClass:[NSString class]];
        return (id)nil; 
        
    }];
    CKFormCellDescriptor* releaseNotesCellDescriptor = [CKFormCellDescriptor cellDescriptorWithValue:productRelease controllerClass:[CKTableViewCellController class]];
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
        CKProductRelease* productRelease = (CKProductRelease*)controller.value;
        UILabel* label = (UILabel*)[controller.tableViewCell.contentView viewWithTag:10000];
        label.text = productRelease.releaseNotes;
        return (id)nil; 
    }];
    [releaseNotesCellDescriptor setSizeBlock:^id(id value) {
        NSDictionary* params = (NSDictionary*)value;
        CKProductRelease* productRelease = (CKProductRelease*)[params object];
        CGSize tableViewSize = [params bounds];
    
        CGSize  size = (productRelease.releaseNotes != nil && ![productRelease.releaseNotes isEqualToString:@""]) ? 
            [productRelease.releaseNotes sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(tableViewSize.width - 20, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap]
            : CGSizeMake(0,0);
        
        return [NSValue valueWithCGSize:CGSizeMake(size.width,size.height + 20)]; 
    }];
    [formController addSectionWithCellDescriptors:[NSArray arrayWithObjects:bundleIdentifierCellDescriptor,appNameCellDescriptor,releaseDateCellDescriptor,releaseNotesCellDescriptor,nil]];
     
    //Setup navigation and push controller
    CKProvisioningControllerBarButtonItem* installButton = [[[CKProvisioningControllerBarButtonItem alloc]initWithTitle:_(@"Install") 
                                                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                                                 target:self 
                                                                                                                 action:@selector(install:)] autorelease];
    installButton.userInfo = productRelease;
    
    formController.rightButton = installButton;
    if(parentController == nil){
        UIViewController* rootController =  self.parentViewController;
        NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
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

- (void)displayProductReleases:(NSArray*)productReleases{
    UIViewController* rootController =  self.parentViewController;
    NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
    if(rootController.modalViewController == nil){
        self.items = productReleases;
        
        NSMutableArray* mappings = [NSMutableArray array];
        CKObjectViewControllerFactoryItem* releaseCellDescriptor = [mappings mapControllerClass:[CKTableViewCellController class] withObjectClass:[CKProductRelease class]];
        [releaseCellDescriptor setCreateBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            controller.name = @"rigoloCell";
            controller.cellStyle = CKTableViewCellStyleSubtitle;
            return (id)nil; 
        }];
        [releaseCellDescriptor setInitBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            controller.tableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            controller.tableViewCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            return (id)nil; 
        }];
        [releaseCellDescriptor setSetupBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            CKProductRelease* productRelease = (CKProductRelease*)controller.value;
            controller.tableViewCell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) %@",productRelease.applicationName,productRelease.buildVersion,(productRelease.recommended ? @"RECOMMANDED" : @"")];
            controller.tableViewCell.detailTextLabel.text = [NSValueTransformer transform:productRelease.releaseDate toClass:[NSString class]];
            return (id)nil; 
            
        }];
        [releaseCellDescriptor setSelectionBlock:^id(id value) {
            CKTableViewCellController* controller = (CKTableViewCellController*)value;
            CKProductRelease* productRelease = (CKProductRelease*)controller.value;
            [self displayProductRelease:productRelease parentController:controller.parentController];
            return (id)nil;
        }];
        [releaseCellDescriptor setFlags:CKItemViewFlagSelectable];
        
        CKObjectPropertyArrayCollection* collection = [CKObjectPropertyArrayCollection collectionWithArrayProperty:[CKObjectProperty propertyWithObject:self keyPath:@"items"]];
        CKObjectTableViewController* tableViewController = [[[CKObjectTableViewController alloc]initWithCollection:collection mappings:mappings]autorelease];
        tableViewController.title = _(@"Versions");
        
        
        UINavigationController* navController = [[[UINavigationController alloc]initWithRootViewController:tableViewController]autorelease];
        tableViewController.leftButton = [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModal:)] autorelease];
        [rootController presentModalViewController:navController animated:YES];
    }
}

- (void)install:(id)sender{
    CKProvisioningControllerBarButtonItem* installButton = (CKProvisioningControllerBarButtonItem*)sender;
    CKProductRelease* productRelease = installButton.userInfo;
    [[UIApplication sharedApplication]openURL:productRelease.provisioningURL];
}

- (void)dismissModal:(id)sender{
    UIViewController* rootController =  self.parentViewController;
    NSAssert(rootController != nil,@"You must initialize the controller with a parentViewController");
    [rootController dismissModalViewControllerAnimated:YES];
}

@end
