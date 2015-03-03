//
//  CKOptionPropertyCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 Wherecloud. All rights reserved.
//

#import "CKOptionPropertyCellController.h"
#import "CKLocalization.h"
#import "NSObject+Bindings.h"

#import "UIViewController+Style.h"
#import "CKStyleManager.h"
#import "CKPopoverController.h"
#import "UIBarButtonItem+BlockBasedInterface.h"
#import "CKDebug.h"


@interface CKOptionPropertyCellController ()
@property (nonatomic,retain) NSArray* values;
@property (nonatomic,retain) NSArray* labels;
@property (nonatomic,retain) NSString* internalBindingContext;

@property (nonatomic,readonly) BOOL multiSelectionEnabled;
@property (nonatomic,retain,readwrite) CKOptionTableViewController* optionsViewController;
@end

@implementation CKOptionPropertyCellController
@synthesize optionCellStyle;
@synthesize values;
@synthesize labels;
@synthesize multiSelectionEnabled;
@synthesize optionsViewController = _optionsViewController;
@synthesize internalBindingContext = _internalBindingContext;
@synthesize presentationStyle = _presentationStyle;
@synthesize optionCellControllerCreationBlock = _optionCellControllerCreationBlock;


- (void)postInit{
    [super postInit];
    
    self.cellStyle = CKTableViewCellStyleIPhoneForm;
    self.optionCellStyle = CKTableViewCellStyleIPhoneForm;
    self.internalBindingContext = [NSString stringWithFormat:@"<%p>_CKOptionPropertyCellController",self];
    self.flags = CKItemViewFlagNone;
    _presentationStyle = CKOptionPropertyCellControllerPresentationStyleDefault;
}


- (void)dealloc{
    [NSObject removeAllBindingsForContext:self.internalBindingContext];
    self.values = nil;
    self.labels = nil;
    [_optionsViewController release];
    [_internalBindingContext release];
    [_optionCellControllerCreationBlock release];
    [super dealloc];
}

- (void)setupLabelsAndValues{
    CKProperty* property = [self objectProperty];
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    
    NSDictionary* valuesAndLabels = nil;
    if(attributes.valuesAndLabels) valuesAndLabels = attributes.valuesAndLabels;
    else if(attributes.enumDescriptor) valuesAndLabels = attributes.enumDescriptor.valuesAndLabels;

    CKAssert(valuesAndLabels != nil,@"No valuesAndLabels or EnumDefinition declared for property %@",property);
    CKOptionPropertyCellControllerSortingBlock sortingBlock = attributes.sortingBlock;
    NSArray* orderedLabels = nil;
    if(sortingBlock){
        orderedLabels = [[valuesAndLabels allKeys]sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString* str1 = obj1;
            NSString* str2 = obj2;
            id value1 = [valuesAndLabels objectForKey:str1];
            id value2 = [valuesAndLabels objectForKey:str2];
            
            return sortingBlock(value1,_(str1),value2,_(str2));
        }];
    }
    else{
        orderedLabels = [[valuesAndLabels allKeys]sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString* str1 = _(obj1);
            NSString* str2 = _(obj2);
            return [str1 compare:str2];
        }];
    }
    
    NSMutableArray* orderedValues = [NSMutableArray array];
    for(NSString* label in orderedLabels){
        id value = [valuesAndLabels objectForKey:label];
        [orderedValues addObject:value];
    }
    
    self.labels = orderedLabels;
    self.values = orderedValues;
}

- (BOOL)multiSelectionEnabled{
    CKProperty* property = [self objectProperty];
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    return (attributes.enumDescriptor && attributes.enumDescriptor.isBitMask) || attributes.multiSelectionEnabled;
}

- (NSString *)labelForValue:(NSInteger)intValue {
	if (intValue < 0
		|| intValue == NSNotFound) {
		
		CKProperty* property = [self objectProperty];
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		NSString* str = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
		return _(str);
	}
	
	if(self.multiSelectionEnabled){
		NSMutableString* str = [NSMutableString string];
		for(int i= 0;i < [self.values count]; ++i){
			NSNumber* v = [self.values objectAtIndex:i];
			NSString* l = [self.labels objectAtIndex:i];
			if(intValue & [v integerValue]){
				if([str length] > 0){
					[str appendFormat:@"%@%@",_(@"_|_"),_(l)];
				}
				else{
					[str appendString:_(l)];
				}
			}
		}
        return str;
	}
	else{
		NSInteger index = intValue;
        NSString* str = (self.labels && index != NSNotFound) ? [self.labels objectAtIndex:index] : [NSString stringWithFormat:@"%ld", (long)intValue];
		return _(str);
	}
	return nil;
}

- (NSArray*)indexesForValue:(NSInteger) value{
	NSMutableArray* indexes = [NSMutableArray array];
	NSInteger intValue = value;
	for(int i= 0;i < [self.values count]; ++i){
		NSNumber* v = [self.values objectAtIndex:i];
		if(intValue & [v integerValue]){
			[indexes addObject:[NSNumber numberWithInt:i]];
		}
	}
	return indexes;
}

- (NSInteger)currentValue{
    CKProperty* property = [self objectProperty];
    if(self.multiSelectionEnabled){
        return [[property value]integerValue];
    }
    else{
        NSInteger index = [self.values indexOfObject:[property value]];
        return index;
    }
    return -1;
}

- (void)viewDidAppear:(UIView *)view{
    [super viewDidAppear:view];
    if(self.containerController.state != CKViewControllerStateDidAppear){
        [self onValueChanged];
    }
}

//


- (void)onValueChanged{
    [self setupLabelsAndValues];
    
    if(self.readOnly){
        self.fixedSize = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        self.fixedSize = NO;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CKProperty* property = [self objectProperty];
    
    self.text = _(property.name);
	self.detailText = [self labelForValue:[self currentValue]];
    if(self.detailText == nil){
        self.detailText = @" ";
    }
    
    __block CKOptionPropertyCellController* bself = self;
    [NSObject beginBindingsContext:self.internalBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
    [property.object bind:property.keyPath withBlock:^(id value){
        bself.detailText = [bself labelForValue:[bself currentValue]];
    }];
    [NSObject endBindingsContext];
    
    
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    self.optionCellControllerCreationBlock = attributes.optionCellControllerCreationBlock;
}

- (void)setupCell:(UITableViewCell *)cell{
    [self onValueChanged];
    [super setupCell:cell];
}


- (void)initTableViewCell:(UITableViewCell *)cell{
    [super initTableViewCell:cell];
    if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
        //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentRight;
        //}  
        //else{
        //    cell.detailTextLabel.numberOfLines = 0;
        //    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        //}
    }  
    
    if(self.readOnly){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setReadOnly:(BOOL)bo{
    [super setReadOnly:bo];
    
    if(bo){
        self.flags = CKItemViewFlagNone;
        return;
    }
    self.flags = CKItemViewFlagSelectable;
}

- (void)didSelect {
    CKProperty* property = [self objectProperty];
    
    [self setupLabelsAndValues];
	
	NSString* propertyNavBarTitle = [NSString stringWithFormat:@"%@_NavBarTitle",property.name];
	NSString* propertyNavBarTitleLocalized = _(propertyNavBarTitle);
	if ([propertyNavBarTitleLocalized isEqualToString:[NSString stringWithFormat:@"%@_NavBarTitle",property.name]]) {
		propertyNavBarTitleLocalized = _(property.name);
	}
    
    CKTableViewController* tableController = (CKTableViewController*)[self containerController];
	if(self.multiSelectionEnabled){
		self.optionsViewController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self indexesForValue:[self currentValue]] multiSelectionEnabled:YES style:[tableController style]] autorelease];
	}
	else{
		self.optionsViewController = [[[CKOptionTableViewController alloc] initWithValues:self.values labels:self.labels selected:[self  currentValue] style:[tableController style]] autorelease];
	}
    self.optionsViewController.optionCellStyle = self.optionCellStyle;
    self.optionsViewController.optionCellControllerCreationBlock = self.optionCellControllerCreationBlock;
	self.optionsViewController.title = propertyNavBarTitleLocalized;
    self.optionsViewController.name = property.keyPath;
    
    [super didSelect];//here because we could want to act on optionsViewController in selectionBlock
    
    CKPopoverController* popover = nil;
    
    //USE PRESENTATION STYLE
    CKPropertyExtendedAttributes* attributes = [property extendedAttributes];
    CKOptionPropertyCellControllerPresentationStyle presentationStyle = self.presentationStyle;
    if(presentationStyle == CKOptionPropertyCellControllerPresentationStyleDefault){
        presentationStyle = attributes.presentationStyle;
    }

    if((presentationStyle == CKOptionPropertyCellControllerPresentationStylePopover) && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad ){
        popover = [[CKPopoverController alloc]initWithContentViewController:self.optionsViewController];
    }
    
    __block CKOptionPropertyCellController* bself = self;
    self.optionsViewController.selectionBlock = ^(CKOptionTableViewController* tableViewController,NSInteger index){
        [NSObject removeAllBindingsForContext:bself.internalBindingContext];
        
        if(bself.multiSelectionEnabled){
            NSArray* indexes = tableViewController.selectedIndexes;
            NSInteger v = 0;
            for(NSNumber* index in indexes){
                v |= [[bself.values objectAtIndex:[index integerValue]]integerValue];
            }
            
            bself.detailText = [bself labelForValue:v];
            [bself setValueInObjectProperty:[NSNumber numberWithInteger:v]];
        }
        else{
            NSInteger index = tableViewController.selectedIndex;
            bself.detailText = [bself labelForValue:index];
            id value = [bself.values objectAtIndex:index];
            [bself setValueInObjectProperty:value];
        }
        
        if(!bself.multiSelectionEnabled){
            if(popover){
                [popover dismissPopoverAnimated:YES];
            }else{
                if(presentationStyle == CKOptionPropertyCellControllerPresentationStyleModal){
                    [bself.containerController dismissModalViewControllerAnimated:YES];
                }else{
                    [bself.containerController.navigationController popViewControllerAnimated:YES];
                }
            }
        }
        
        CKProperty* property = [bself objectProperty];
        [NSObject beginBindingsContext:bself.internalBindingContext policy:CKBindingsContextPolicyRemovePreviousBindings];
        [property.object bind:property.keyPath withBlock:^(id value){
            bself.detailText = [bself labelForValue:[bself currentValue]];
        }];
        [NSObject endBindingsContext];
    };
    
    if(popover){
        [popover presentPopoverFromRect:self.view.frame inView:[self.view superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else{
        if(presentationStyle == CKOptionPropertyCellControllerPresentationStyleModal){
            __block CKOptionTableViewController* bcontroller = self.optionsViewController;
            self.optionsViewController.leftButton = [[[UIBarButtonItem alloc]initWithTitle:_(@"Close") style:UIBarButtonItemStyleBordered block:^{
                [bcontroller dismissModalViewControllerAnimated:YES];
            }]autorelease];
            
            UINavigationController* nav = [[[UINavigationController alloc]initWithRootViewController:self.optionsViewController]autorelease];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self.containerController presentModalViewController:nav animated:YES];
        }else{
            [self.containerController.navigationController pushViewController:self.optionsViewController animated:YES];
        }
    }
}


@end
