//
//  CKNSStringPropertyCellController.m
//  AppCoreKit
//
//  Created by Sebastien Morel.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//


#import "CKNSStringPropertyCellController.h"
#import "CKProperty.h"
#import "NSObject+Bindings.h"
#import "CKLocalization.h"
#import "CKTableViewCellController+Responder.h"
#import "NSValueTransformer+Additions.h"

#import "CKSheetController.h"
#import "UIView+Positioning.h"

//Until we get rid of this class for CKPropertyStringViewController
#import "CKPropertyStringViewController.h"

#define TEXTFIELD_TAG 50000

@interface CKTableViewCellController()
- (CGFloat)computeContentViewSize;
@end

@interface CKNSStringPropertyCellController()
@property (nonatomic,retain,readwrite) UITextField* textField;
@end

@implementation CKNSStringPropertyCellController{
	UITextField* _textField;
}

@synthesize textField = _textField;
@synthesize textInputFormatterBlock = _textInputFormatterBlock;

-(void)dealloc{
	[_textField release];
    [_textInputFormatterBlock release];
	[super dealloc];
}


- (void)postInit{
    [super postInit];
    self.flags = CKItemViewFlagNone;
}

//pas utiliser load cell mais initCell pour application des styles ...
- (void)initTableViewCell:(UITableViewCell*)cell{
	[super initTableViewCell:cell];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    UITextField *txtField = [[[UITextField alloc] initWithFrame:cell.contentView.bounds] autorelease];
    self.textField = txtField;
    
	_textField.tag = TEXTFIELD_TAG;
	_textField.borderStyle = UITextBorderStyleNone;
	_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	_textField.textAlignment = UITextAlignmentLeft;
	_textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    //_textField.hidden = YES; //will get displayed in setup depending on the model
    [cell.contentView addSubview:_textField];
    
    if(self.cellStyle == CKTableViewCellStyleIPhoneForm){
        //if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            _textField.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1];
            cell.detailTextLabel.numberOfLines = 0;
            cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        //}  
        //else{
        //    _textField.textColor = [UIColor blackColor];
        //    cell.detailTextLabel.numberOfLines = 0;
        //    cell.detailTextLabel.textAlignment = UITextAlignmentLeft;
        //}
    }  
    
    if(self.cellStyle == CKTableViewCellStyleIPadForm
       || self.cellStyle == CKTableViewCellStyleIPhoneForm
       || self.cellStyle == CKTableViewCellStyleSubtitle2){
        _textField.autoresizingMask = UIViewAutoresizingNone;
    }
}

- (void)textFieldChanged:(id)value{
    [self setValueInObjectProperty:value];
}

- (void)setupCell:(UITableViewCell *)cell {
	[super setupCell:cell];
	[cell clearBindingsContext];
    
    self.textField = (UITextField*)[cell.contentView viewWithTag:TEXTFIELD_TAG];
	
	CKProperty* model = self.objectProperty;
	
	CKClassPropertyDescriptor* descriptor = [model descriptor];
    
    if(([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad && self.cellStyle == CKTableViewCellStyleIPadForm)
       || self.cellStyle != CKTableViewCellStyleIPhoneForm){
        self.text = _(descriptor.name);
    }else{
        self.text = nil;
    }
	
	self.detailText = nil;
	
    [cell beginBindingsContextByRemovingPreviousBindings];
    [model.object bind:model.keyPath toObject:self withKeyPath:@"detailText"];
    [cell endBindingsContext];
    
	if([model isReadOnly] || self.readOnly){
        self.textField.hidden = YES;
        
        self.fixedSize = YES;
        _textField.delegate = nil;
	}
	else{
        if(_textField){
            if(self.cellStyle == CKTableViewCellStyleIPhoneForm
               /*&& [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone*/){
                self.fixedSize = YES;
            }
            else{
                self.fixedSize = NO;
            }
            
            __block CKNSStringPropertyCellController* bself = self;
            
            [cell beginBindingsContextByRemovingPreviousBindings];
            [model.object bind:model.keyPath executeBlockImmediatly:YES  withBlock:^(id value) {
                NSString* str = [value isKindOfClass:[NSString class]] ? value : nil;
                if(![bself.textField.text isEqualToString:str]){
                    bself.textField.text = str;
                }
            }];

            [[NSNotificationCenter defaultCenter] bindNotificationName:UITextFieldTextDidChangeNotification object:self.textField 
                                                             withBlock:^(NSNotification *notification) {
                                                                 [self textFieldChanged:self.textField.text];
                                                             }];
            [cell endBindingsContext];
            
            NSString* placeholerText = [NSString stringWithFormat:@"%@_Placeholder",descriptor.name];
            self.textField.placeholder = _(placeholerText);
            self.textField.hidden = NO;
            _textField.delegate = self;
            
            self.detailText = nil;
        }
	}
}

- (void)rotateCell:(UITableViewCell*)cell  animated:(BOOL)animated{
	[super rotateCell:cell animated:animated];
}

#pragma mark UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIToolbar* toolbar = [self navigationToolbar];
    if(toolbar){
        self.textField.inputAccessoryView = toolbar;
    }
    

    if([self hasNextResponder]){
        self.textField.returnKeyType = UIReturnKeyNext;
    }
    else{
        self.textField.returnKeyType = UIReturnKeyDone;
    }
    
	[self scrollToRow];
    
	[self didBecomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[self didResignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.returnKeyType == UIReturnKeyNext ){
        [self activateNextResponder];
    }else{
        if(self.returnKeyBlock){
            self.returnKeyBlock(self);
        }else{
            [textField resignFirstResponder];
        }
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    CKPropertyExtendedAttributes* attributes = [[self objectProperty]extendedAttributes];
    
    CKInputTextFormatterBlock formatterBlock = self.textInputFormatterBlock;
    if(!formatterBlock){
        formatterBlock = [attributes textInputFormatterBlock];
    }
    
    if(formatterBlock){
        BOOL bo = formatterBlock(textField,range,string);
        [self textFieldChanged:self.textField.text];
        return bo;
    }
    
    NSInteger min = [attributes minimumLength];
    NSInteger max = [attributes maximumLength];
	if (range.length>0) {
        if(min >= 0 && range.location < min){
            return NO;
        }
		return YES;
	} else {
        if(max >= 0 && range.location >= max){
            return NO;
        }
        return YES;
	}
    return YES;
}

#pragma mark Keyboard

- (void)keyboardDidShow:(NSNotification *)notification {
    [self scrollToRowAfterDelay:0];
}


- (BOOL)hasResponder{
	return ![self.objectProperty isReadOnly];
}

- (UIView*)nextResponder:(UIView*)view{
    if(view == nil){
        return [self.tableViewCell viewWithTag:TEXTFIELD_TAG];
    }
	return nil;
}

@end
