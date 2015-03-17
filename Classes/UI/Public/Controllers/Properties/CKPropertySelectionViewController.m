//
//  CKPropertySelectionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-13.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertySelectionViewController.h"
#import "CKTableViewCellController.h"
#import "CKOptionTableViewController.h"
#import "UIBarButtonItem+BlockBasedInterface.h"
#import "CKPopoverController.h"
#import "NSValueTransformer+Additions.h"
#import "CKResourceManager.h"

@implementation CKPropertySelectionValue

- (void)dealloc{
    [_property release];
    [_label release];
    [_value release];
    [super dealloc];
}

@end

@interface CKPropertySelectionViewController ()
@property(nonatomic,assign,readwrite) BOOL multiSelectionEnabled;
@property(nonatomic,retain) NSMutableArray* values;
@end

@implementation CKPropertySelectionViewController

- (void)dealloc{
    [_values release];
    [_propertyNameLabel release];
    [_selectionControllerFactory release];
    [_sortBlock release];
    [_multiSelectionSeparatorString release];
    [super dealloc];
}

- (id)initWithProperty:(CKProperty*)property readOnly:(BOOL)readOnly{
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    NSAssert(attributes.enumDescriptor != nil || attributes.valuesAndLabels != nil,@"CKPropertySelectionViewController needs you to declare an enum descriptor or valuesAndLabels in your property's extended attributes");

    if(attributes.enumDescriptor ){
        return [self initWithProperty:property enumDescriptor:attributes.enumDescriptor readOnly:readOnly];
    }
    
    BOOL isCollection = [self.property isContainer];
    
    return [self initWithProperty:property valuesAndLabels:attributes.valuesAndLabels multiSelectionEnabled:isCollection || attributes.multiSelectionEnabled readOnly:readOnly];
}

- (id)initWithProperty:(CKProperty*)property enumDescriptor:(CKEnumDescriptor*)enumDescriptor readOnly:(BOOL)readOnly{
    return [self initWithProperty:property valuesAndLabels:enumDescriptor.valuesAndLabels multiSelectionEnabled:enumDescriptor.isBitMask readOnly:readOnly];
}

- (id)initWithProperty:(CKProperty*)property valuesAndLabels:(NSDictionary*)valuesAndLabels readOnly:(BOOL)readOnly{
    return [self initWithProperty:property valuesAndLabels:valuesAndLabels multiSelectionEnabled:[property isContainer] readOnly:readOnly];
}

- (id)initWithProperty:(CKProperty*)property valuesAndLabels:(NSDictionary*)valuesAndLabels multiSelectionEnabled:(BOOL)multiSelectionEnabled readOnly:(BOOL)readOnly{
    self = [super initWithProperty:property readOnly:readOnly];
    self.multiSelectionEnabled = multiSelectionEnabled;
    
    self.values = [NSMutableArray array];
    for(NSString* label in [valuesAndLabels allKeys]){
        id value = [valuesAndLabels objectForKey:label];
        
        CKPropertySelectionValue* v = [[CKPropertySelectionValue alloc]init];
        v.property = self.property;
        v.label = label;
        v.value = value;
        [self.values addObject:v];
    }
    return self;
}

- (void)postInit{
    CKPropertyExtendedAttributes* attributes = [self.property extendedAttributes];
    self.propertyNameLabel = _(self.property.name);
    self.hideDisclosureIndicatorWhenImageIsAvailable = YES;
    
    self.presentationStyle = CKOptionPropertyCellControllerPresentationStyleDefault;
    self.multiSelectionSeparatorString = @"\n";
    
    self.collectionCellController.flags = CKItemViewFlagSelectable;
    if([self.collectionCellController isKindOfClass:[CKTableViewCellController class]]){
        CKTableViewCellController* tableViewCellController = (CKTableViewCellController*)self.collectionCellController;
        tableViewCellController.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    self.collectionCellController.flags = self.readOnly ? CKItemViewFlagNone : CKItemViewFlagSelectable;
}

- (NSString *)labelForNumberValue:(NSInteger)intValue {
    if (intValue < 0 || intValue == NSNotFound) {
        CKClassPropertyDescriptor* descriptor = [self.property descriptor];
        NSString* str = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
        return _(str);
    }
    
    if(self.multiSelectionEnabled){
        NSMutableString* str = [NSMutableString string];
        NSArray* sorted = self.sortBlock ? [self.values sortedArrayUsingComparator:self.sortBlock] : self.values;
        for(CKPropertySelectionValue* v in sorted){
            if(intValue & [v.value integerValue]){
                if([str length] > 0){
                    [str appendFormat:@"%@%@",self.multiSelectionSeparatorString,_(v.label)];
                }
                else{
                    [str appendString:_(v.label)];
                }
            }
        }
        return str;
    }
    else{
        for(CKPropertySelectionValue* v in self.values){
            if(intValue == [v.value integerValue]){
                return _(v.label);
            }
        }
        
        CKClassPropertyDescriptor* descriptor = [self.property descriptor];
        NSString* str = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
        return _(str);
    }
    return nil;
}

- (NSString*)labelForCollectionValue:(id)collection{
    if (self.property.count <= 0) {
        CKClassPropertyDescriptor* descriptor = [self.property descriptor];
        NSString* str = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
        return _(str);
    }
    
    NSMutableString* str = [NSMutableString string];
    NSArray* sorted = self.sortBlock ? [self.values sortedArrayUsingComparator:self.sortBlock] : self.values;
    for(CKPropertySelectionValue* v in sorted){
        if([self.property containsObject: v.value ]){
            if([str length] > 0){
                [str appendFormat:@"%@%@",self.multiSelectionSeparatorString,_(v.label)];
            }
            else{
                [str appendString:_(v.label)];
            }
        }
    }
    
    return str;
}

- (NSString*)labelForObjectValue:(id)object{
    for(CKPropertySelectionValue* v in self.value){
        if([self.property.value isEqual:object]){
            return _(v.label);
        }
    }
    
    CKClassPropertyDescriptor* descriptor = [self.property descriptor];
    NSString* str = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
    return _(str);
}

- (NSString*)labelForPropertyValue:(id)value{
    if([self.property isContainer])
        return [self labelForCollectionValue:value ];
    else if([self.property isNumber])
        return [self labelForNumberValue:[value integerValue]];
    return [self labelForObjectValue:value];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UILabel* PropertyNameLabel = [[UILabel alloc]init];
    PropertyNameLabel.name = @"PropertyNameLabel";
    PropertyNameLabel.font = [UIFont boldSystemFontOfSize:17];
    PropertyNameLabel.textColor = [UIColor blackColor];
    PropertyNameLabel.numberOfLines = 1;
    PropertyNameLabel.marginRight = 10;
    
    UILabel* ValueLabel = [[UILabel alloc]init];
    ValueLabel.name = @"ValueLabel";
    ValueLabel.font = [UIFont systemFontOfSize:14];
    ValueLabel.textColor = [UIColor blackColor];
    ValueLabel.numberOfLines = 1;
    ValueLabel.flexibleWidth = 1;
    ValueLabel.textAlignment = UITextAlignmentRight;
    
    UIImageView* ValueImageView = [[UIImageView alloc]init];
    ValueImageView.name = @"ValueImageView";
    ValueImageView.fixedSize = CGSizeMake(40,40);
    ValueImageView.marginLeft = 10;
    ValueImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CKHorizontalBoxLayout* hBox = [[CKHorizontalBoxLayout alloc]init];
    hBox.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[PropertyNameLabel,ValueLabel,ValueImageView]];
    
    self.view.layoutBoxes = [CKArrayCollection collectionWithObjectsFromArray:@[hBox]];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!self.view)
        return;
    
    [self.view beginBindingsContextByRemovingPreviousBindings];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContext];
}


- (void)setupBindings{
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UILabel* ValueLabel = [self.view viewWithName:@"ValueLabel"];
    
    UIImageView* ValueImageView = [self.view viewWithName:@"ValueImageView"];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        ValueLabel.text = [bself labelForPropertyValue:value];
        
        UIImage* image = [CKResourceManager imageNamed:[self imageNameForValue:self.property.value]];
        ValueImageView.hidden = image == nil;
        ValueImageView.image = image;
        
        if(bself.hideDisclosureIndicatorWhenImageIsAvailable){
            if([bself.collectionCellController isKindOfClass:[CKTableViewCellController class]]){
                CKTableViewCellController* tableViewCellController = (CKTableViewCellController*)bself.collectionCellController;
                if(!image){
                    tableViewCellController.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }else{
                    tableViewCellController.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
    }];
}

- (void)didSelect{
    [super didSelect];
    
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    CKFormTableViewController* editionViewController = [CKFormTableViewController controller];
    editionViewController.title = _(self.property.name);
    
    CKCollectionCellControllerFactory* factory = self.selectionControllerFactory ? self.selectionControllerFactory : [self defaultFactory];
    
    NSMutableArray* cells = [NSMutableArray array];
    
    NSArray* sorted = self.sortBlock ? [self.values sortedArrayUsingComparator:self.sortBlock] : self.values;
    
    NSInteger index = 0;
    for(CKPropertySelectionValue* v in sorted){
        CKTableViewCellController* cell = [factory controllerForObject:v
                                                           atIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                              collectionViewController:editionViewController];
        
        CKCallback* olSelectionCallback = cell.selectionCallback;
        [cell setSelectionBlock:^(CKTableViewCellController *controller) {
            if(olSelectionCallback){
                [olSelectionCallback execute:controller];
            }
            
            if([v.property isContainer]){
                if([v.property containsObject:v.value]){
                    [v.property removeObject:v.value];
                }else{
                    [v.property addObject:v.value];
                }
            }else if([v.property isNumber]){
                NSInteger intV = [v.value integerValue];
                NSInteger intP = [v.property.value integerValue];
                if(bself.multiSelectionEnabled){
                    if(intP & intV){
                        [v.property setValue:@(intP &~ intV)];
                    }else{
                        [v.property setValue:@(intP | intV)];
                    }
                }else{
                    [v.property setValue:@(intV)];
                }
            }else{
                [v.property setValue:v.value];
            }
        }];
        
        [cells addObject:cell];
        
        ++index;
    };
    
    CKFormSection* section = [CKFormSection sectionWithCellControllers:cells];
    [editionViewController addSections:@[section]];
    
    [self presentEditionViewController:editionViewController];
}

- (NSString*)imageNameForValue:(id)value{
    NSString* strValue = nil;
    for(CKPropertySelectionValue* v in self.values){
        if([value isEqual:v.value]){
            strValue = v.label;
            break;
        }
    }
    
    if(!strValue)
        return nil;
    
    return [NSString stringWithFormat:@"icon_%@",strValue];
}

- (CKCollectionCellControllerFactory*)defaultFactory{
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    CKCollectionCellControllerFactory* factory = [CKCollectionCellControllerFactory factory];
    [factory addItemForObjectOfClass:[CKPropertySelectionValue class]
         withControllerCreationBlock:^CKTableViewCellController *(id object, NSIndexPath *indexPath) {
             CKPropertySelectionValue* v = (CKPropertySelectionValue*)object;
             
             UIImage* image = [CKResourceManager imageNamed:[self imageNameForValue:v.value]];
             
             CKTableViewCellController* cellController = [CKTableViewCellController cellControllerWithTitle:_(v.label) image:image action:^(CKTableViewCellController *controller) {
                 
             }];
             
             [cellController setSetupBlock:^(CKTableViewCellController *controller, UITableViewCell *cell) {
                 [cell beginBindingsContextByRemovingPreviousBindings];
                 [v.property.object bind:v.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
                     BOOL selected = NO;
                     
                     if([v.property isContainer]){
                         selected = [v.property containsObject:v.value];
                     }else if([v.property isNumber]){
                         NSInteger intV = [v.value integerValue];
                         NSInteger intP = [v.property.value integerValue];
                         if(bself.multiSelectionEnabled){
                             selected = (intP & intV);
                         }else{
                             selected = (intV == intP);
                         }
                     }else{
                         selected = [v.property.value isEqual:v.value];
                     }
                     
                     cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                 }];
                 [cell endBindingsContext];
             }];
             return cellController;
    }];
    
    return factory;
}

- (void)presentEditionViewController:(CKFormTableViewController*)controller{
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    CKPropertySelectionPresentationStyle style = self.presentationStyle;
    if(style == CKPropertySelectionPresentationStyleDefault){
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            style = CKPropertySelectionPresentationStylePopover;
        }else if(self.navigationController){
            style = CKPropertySelectionPresentationStylePush;
        }else{
            style = CKPropertySelectionPresentationStyleModal;
        }
    }
    
    switch(style){
        case CKPropertySelectionPresentationStylePopover:{
            CKPopoverController* popover = [[CKPopoverController alloc]initWithContentViewController:controller];
            [popover presentPopoverFromRect:self.view.frame inView:[self.view superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            __unsafe_unretained CKPopoverController* bPopover = popover;
            [controller beginBindingsContextByRemovingPreviousBindings];
            if(!self.multiSelectionEnabled){
                [self.property.object bind:self.property.keyPath withBlock:^(id value) {
                    [bPopover dismissPopoverAnimated:YES];
                }];
            }
            [controller endBindingsContext];
            break;
        }
        case CKPropertySelectionPresentationStylePush:{
            [self.navigationController pushViewController:controller animated:YES];
            
            [controller beginBindingsContextByRemovingPreviousBindings];
            if(!self.multiSelectionEnabled){
                [self.property.object bind:self.property.keyPath withBlock:^(id value) {
                    [bself.navigationController popViewControllerAnimated:YES];
                }];
            }
            [controller endBindingsContext];
            
            break;
        }
        case CKPropertySelectionPresentationStyleModal:{
            UINavigationController* nav = [[[UINavigationController alloc]initWithRootViewController:controller]autorelease];
            
            controller.leftButton = [UIBarButtonItem barButtonItemWithTitle:_(@"Close") style:UIBarButtonItemStyleBordered block:^{
                [bself.collectionViewController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [controller beginBindingsContextByRemovingPreviousBindings];
            if(!self.multiSelectionEnabled){
                [self.property.object bind:self.property.keyPath withBlock:^(id value) {
                    [bself.collectionViewController dismissViewControllerAnimated:YES completion:nil];
                }];
            }
            [controller endBindingsContext];
            
            [bself.collectionViewController presentViewController:controller animated:YES completion:nil];
            break;
        }
        case CKPropertySelectionPresentationStyleInlinePicker:{
            //TODO When we'll have a CKPickerViewController
            break;
        }
        case CKPropertySelectionPresentationStylePopoverPicker:{
            //TODO When we'll have a CKPickerViewController
            break;
        }
    }
}

@end
