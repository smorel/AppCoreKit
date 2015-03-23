//
//  CKPropertySelectionViewController.m
//  AppCoreKit
//
//  Created by Sebastien Morel on 2015-03-13.
//  Copyright (c) 2015 Wherecloud. All rights reserved.
//

#import "CKPropertySelectionViewController.h"
#import "CKTableViewCellController.h"
#import "CKTableViewContentCellController.h"
#import "CKOptionTableViewController.h"
#import "UIBarButtonItem+BlockBasedInterface.h"
#import "CKPopoverController.h"
#import "NSValueTransformer+Additions.h"
#import "CKResourceManager.h"
#import "CKStyleManager.h"
#import "UIViewController+Style.h"
#import "CKReusableViewController+ResponderChain.h"
#import "CKSheetController.h"
#import "CKTableViewController.h"

#import "CKPickerViewViewController.h"

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
    [_editionControllerFactory release];
    [_sortBlock release];
    [_multiSelectionSeparatorString release];
    [super dealloc];
}

- (void)editionControllerAppearanceExtendedAttributes:(CKPropertyExtendedAttributes*)attributes{
    attributes.enumDescriptor = CKEnumDefinition(@"CKPropertyEditionAppearanceStyle",
                                                 CKPropertyEditionAppearanceStyleDefault,
                                                 CKPropertyEditionAppearanceStyleList,
                                                 CKPropertyEditionAppearanceStylePicker);
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
    
    CKPropertyExtendedAttributes* attributes = [self.property extendedAttributes];
    self.propertyNameLabel = _(self.property.name);
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return self;
}

- (void)postInit{
    [super postInit];
    
    self.hideDisclosureIndicatorWhenImageIsAvailable = YES;
    
    self.editionControllerAppearance = CKPropertyEditionAppearanceStyleDefault;
    self.editionControllerPresentationStyle = CKPropertyEditionPresentationStyleDefault;
    self.multiSelectionSeparatorString = @"\n";
    
    self.flags = CKViewControllerFlagsSelectable;
    
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
    
    if([self isLayoutDefinedInStylesheet])
        return;
    
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
    
    [self.view beginBindingsContextWithScope:@"CKPropertySelectionViewController"];
    [self setupBindings];
    [self.view endBindingsContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view clearBindingsContextWithScope:@"CKPropertySelectionViewController"];
}


- (void)setupBindings{
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    UILabel* PropertyNameLabel = [self.view viewWithName:@"PropertyNameLabel"];
    PropertyNameLabel.text = self.propertyNameLabel;
    
    UILabel* ValueLabel = [self.view viewWithName:@"ValueLabel"];
    
    UIImageView* ValueImageView = [self.view viewWithName:@"ValueImageView"];
    
    [self.property.object bind:self.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        ValueLabel.text = [bself labelForPropertyValue:value];
        
        UIImage* image = [CKResourceManager imageNamed:[bself imageNameForValue:bself.property.value]];
        ValueImageView.hidden = image == nil;
        ValueImageView.image = image;
        
        if(bself.hideDisclosureIndicatorWhenImageIsAvailable){
            bself.tableViewCell.accessoryType = !image ? self.accessoryType : UITableViewCellAccessoryNone;
        }
    }];
}

- (void)didSelect{
    [super didSelect];
    if(self.isFirstResponder){
        if(self.editionControllerPresentationStyle == CKPropertyEditionPresentationStyleInline){
            [self resignFirstResponder];
        }
    }else{
        [self becomeFirstResponder];
    }
}

- (BOOL)hasResponder{
    return YES;
}

- (void)becomeFirstResponder{
    [super becomeFirstResponder];
    
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    UIViewController* editionViewController = nil;
    switch(self.editionControllerAppearance){
        case CKPropertyEditionAppearanceStyleDefault:
        case CKPropertyEditionAppearanceStyleList:{
            CKTableViewController* table = [[[CKTableViewController alloc]initWithStyle:UITableViewStylePlain]autorelease];
            table.endEditingViewWhenScrolling = NO;
            
            NSMutableArray* selectedIndexPaths = [NSMutableArray array];
            NSArray* controllers = [self cellsForEditionController:table selectedIndexPaths:selectedIndexPaths];
            
            CKSection* section = [CKSection sectionWithControllers:controllers];
            [table addSections:@[section] animated:NO];
            
            editionViewController = table;
            break;
        }
        case CKPropertyEditionAppearanceStylePicker:{
            CKPickerViewViewController* picker = [CKPickerViewViewController controller];
            
            NSMutableArray* selectedIndexPaths = [NSMutableArray array];
            NSArray* controllers = [self cellsForEditionController:picker selectedIndexPaths:selectedIndexPaths];
            CKSection* section = [CKSection sectionWithControllers:controllers];
            [picker addSections:@[section] animated:NO];
            
            picker.selectedIndexPaths = selectedIndexPaths;
            
            editionViewController = picker;
            break;
        }
    }
    
    
    [self presentEditionViewController:editionViewController
                     presentationStyle:self.editionControllerPresentationStyle
    shouldDismissOnPropertyValueChange:!self.multiSelectionEnabled];
}

- (NSArray*)cellsForEditionController:(UIViewController*)editionController selectedIndexPaths:(NSMutableArray*)selectedIndexPath{
    CKReusableViewControllerFactory* factory = self.editionControllerFactory ? self.editionControllerFactory : [self defaultFactory];
    
    NSMutableArray* cells = [NSMutableArray array];
    
    NSArray* sorted = self.sortBlock ? [self.values sortedArrayUsingComparator:self.sortBlock] : self.values;
    
    NSInteger index = 0;
    for(CKPropertySelectionValue* v in sorted){
        CKReusableViewController* cell = [factory controllerForObject:v
                                                                         indexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                                               containerController:editionController];
        
        [cells addObject:cell];
        
        if([self isValueSelected:v]){
            [selectedIndexPath addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        
        ++index;
    };

    return cells;
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


- (BOOL)isValueSelected:(CKPropertySelectionValue*)v{
    BOOL selected = NO;
    
    if([v.property isContainer]){
        selected = [v.property containsObject:v.value];
    }else if([v.property isNumber]){
        NSInteger intV = [v.value integerValue];
        NSInteger intP = [v.property.value integerValue];
        if(self.multiSelectionEnabled){
            selected = (intP & intV);
        }else{
            selected = (intV == intP);
        }
    }else{
        selected = [v.property.value isEqual:v.value];
    }
    
    return selected;
}

- (void)setValueSelected:(CKPropertySelectionValue*)v{
    if([v.property isContainer]){
        if([v.property containsObject:v.value]){
            [v.property removeObject:v.value];
        }else{
            [v.property addObject:v.value];
        }
    }else if([v.property isNumber]){
        NSInteger intV = [v.value integerValue];
        NSInteger intP = [v.property.value integerValue];
        if(self.multiSelectionEnabled){
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
}

- (CKReusableViewController*)defaultControllerForValue:(CKPropertySelectionValue*)v{
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    CKStandardContentViewController* cell = [CKStandardContentViewController controllerWithTitle:_(v.label) imageName:[self imageNameForValue:v.value] action:^{
        [bself setValueSelected:v];
    }];
    
    __unsafe_unretained CKStandardContentViewController* bcell = cell;
    
    [cell beginBindingsContextByRemovingPreviousBindings];
    [v.property.object bind:v.property.keyPath executeBlockImmediatly:YES withBlock:^(id value) {
        BOOL selected = [bself isValueSelected:v];
        bcell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }];
    [cell endBindingsContext];
    
    return cell;
}

- (CKReusableViewControllerFactory*)defaultFactory{
    __unsafe_unretained CKPropertySelectionViewController* bself = self;
    
    CKReusableViewControllerFactory* factory = [CKReusableViewControllerFactory factory];
    [factory registerFactoryForObjectOfClass:[CKPropertySelectionValue class]
                                     factory:^CKReusableViewController *(id object, NSIndexPath *indexPath) {
            return [bself defaultControllerForValue:object];
    }];
    
    return factory;
}

@end
